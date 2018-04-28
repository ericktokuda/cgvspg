#!/usr/bin/env python3
"""CG vs PG Classification script using cross-validation
"""

import numpy as np
import os
from os.path import expanduser
import sys
sys.path.append('tools')
from numpy import genfromtxt
from sklearn import svm
import sklearn
import csv
import utils
import logging
import multiprocessing as multipr
import itertools
import pathlib
from time import time
import argparse
from sklearn.model_selection import GridSearchCV

HOME = str(pathlib.Path.home())
UNKNOWN_KERNEL_TYPE = 'UNKNOWN'

def load_indices_and_labels_crossvalidation(indicesdir, nfolds):
    """Load indices and labels in @indicesdir folder

    Args:
    indicesdir(str): path to the folder containg the indices
    nfolds(int): number of indices/labels sets

    Returns:
    2-uple: indices and labels. Both are dicts with @nfolds elements
    """

    indices = {}
    labels = {}
    for k in range(nfolds):
        indicespath = os.path.join(indicesdir, 'ids_fold{}.csv'.format(k))
        indices[k] = genfromtxt(indicespath, dtype=int)
        labelspath = os.path.join(indicesdir, 'labels_fold{}.csv'.format(k))
        labels[k] = genfromtxt(labelspath, dtype=int)
    return indices, labels

def write_results(header, nfeatures, hits, samplesz, traintime, predtime,
                  avgacc, foldsvar, totaltime, c, ker, outdir):
    # TODO: Export results in json format
    # TODO: Unify all exports here (many calls scattered in the code)

    resultspath = os.path.join(outdir, 'results.log')
    resultsfh = open(resultspath, 'w')
    resultsfh.write(header + '\n')
    resultsfh.write('Number of features:\n')
    resultsfh.write('{}\n'.format(nfeatures))
    resultsfh.write('Number of hits, training and prediction time per fold:\n')
    for i in range(len(traintime)):
        resultsfh.write('{}/{},{},{}\n'.format(hits[i], samplesz[i], traintime[i],
                                               predtime[i]))
    resultsfh.write('Folds average accuracy and variance:\n')
    resultsfh.write('{},{}\n'.format(avgacc, foldsvar))
    resultsfh.write('Overall time:\n')
    resultsfh.write('{}\n'.format(totaltime))
    resultsfh.write('SVM kernel and C param:\n')
    resultsfh.write('{},{}\n'.format(ker, c))
    resultsfh.close()

def crossvalidate(featurespath, indicesdir, nfolds, outdir):
    """Perform cross validation using the features set provided by
    @featurespath, using the indices and labels in @indicesdir,
    and write the results in outdir

    Args:
    featurespath(str): path to the features set
    indicesdir(str): path to the folder containing the indices and labels
    nfolds(int): Number of folds of the cross-validation

    Returns:
    ret
    """

    print(featurespath)
    resultspath = os.path.join(outdir, 'results.log')
    if os.path.exists(resultspath): return

    start = time()
    features = genfromtxt(featurespath, delimiter=',')
    features = sklearn.preprocessing.scale(features, axis=0)

    indices, labels = load_indices_and_labels_crossvalidation(indicesdir, nfolds)

    samplesz = []
    hits = []
    traintime = []
    predtime = []
    tpsum = 0

    ker = UNKNOWN_KERNEL_TYPE # Flag to compute grid search
    c = -1

    acc = np.ndarray([5,])
    for k in range(nfolds):
        valfold = k
        trainfolds = list(range(nfolds))
        trainfolds.remove(k)

        valfeatures = features[indices[valfold]]
        vallabels = labels[valfold]

        trainfeatures = np.ndarray((0, features.shape[1]))
        trainlabels = np.array([])

        for f in trainfolds:
            trainfeatures = np.concatenate((trainfeatures, features[indices[f]]),
                                           axis=0)
            trainlabels = np.concatenate((trainlabels, labels[f]), axis=0)

        tp, decvalues, trtime, prtime, c, ker = trainval(trainfeatures, trainlabels,
                                                      valfeatures, vallabels, c, ker)
        traintime.append(trtime)
        predtime.append(prtime)
        hits.append(tp)
        tpsum += tp
        samplesz.append(len(decvalues))

        decvaluespath = os.path.join(outdir, 'decvalues_fold{}.csv'.format(k))
        with open(decvaluespath, 'w') as fh2:
            for v in decvalues:
                fh2.write('{}\n'.format(v))
        acc[k] = tp/valfeatures.shape[0]

    avgacc = tpsum / np.sum(np.array(samplesz))
    totaltime = time() - start
    foldsvar = np.var(acc, ddof=1)
    write_results(featurespath, features.shape[1], hits, samplesz, traintime,
                  predtime, avgacc, foldsvar, totaltime, c, ker, outdir)

def trainval(trainfeatures, trainlabels, valfeatures, vallabels, inc, inker):
    """Train and predict using SVM

    Args:
    trainfeatures(np.ndarray): each row represent the features of a sample
    trainlabels(np.array): labels (-1 or +1)
    valfeatures(np.ndarray): validation features
    valfeatures(np.array): labels (-1 or +1)
    inc(float): input C parameter of the svm
    inker(str): input kernel type
    """

    parameters = {'kernel':('linear', 'rbf'), 'C':[0.1, 1, 10]}
    svc = svm.SVC()
    if inker == UNKNOWN_KERNEL_TYPE:
        clf = GridSearchCV(svc, parameters)
        clf.fit(trainfeatures, trainlabels)
        c = clf.best_params_['C']
        ker = clf.best_params_['kernel']
    else:
        c = inc
        ker = inker

    clf = sklearn.svm.SVC(C=c, cache_size=5000, class_weight=None,coef0=0.0,
                          decision_function_shape='ovr', degree=3, gamma='auto',
                          kernel=ker, max_iter=20000, probability=False,
                          random_state=None, shrinking=True, tol=0.001,
                          verbose=True)
    start = time()
    clf.fit(trainfeatures, trainlabels)
    aftertrain = time()
    predicted = clf.predict(valfeatures)
    afterprediction = time()
    decvalues = clf.decision_function(valfeatures)

    hits = np.equal(predicted, vallabels)
    tp = np.sum(hits)
    acc = tp / valfeatures.shape[0]
    traintime = aftertrain - start
    predtime = afterprediction - aftertrain

    return tp, decvalues, traintime, predtime, c, ker

def crossvalidate_listinput(l):
    crossvalidate(*l)

def main_classification(featuresdir, indicesdir, outdir, nprocs=1):

    #if os.path.isdir(outdir):
        #print('{} exists. Aborting.'.format(outdir))
        #return

    if not os.path.isdir(outdir): os.mkdir(outdir)
    auxlist =  os.listdir(featuresdir)
    files = []
    resultsdirs = []

    for e in auxlist:
        featurespath = os.path.join(featuresdir, e)
        if not e.endswith('.csv'): continue
        files.append(featurespath)
        meth = e.split('.')[0]
        resultsdir = os.path.join(outdir, meth)
        resultsdirs.append(resultsdir)
        if not os.path.isdir(resultsdir): os.mkdir(resultsdir)

    params = []
    for j in range(len(files)):
        params.append([files[j], indicesdir, 5, resultsdirs[j]])

    pool = multipr.Pool(nprocs)
    pool.map(crossvalidate_listinput, params)

def classify_simple_voting(indicesdir, nfolds, resdir, outdir):
    classify_weighted_voting(indicesdir, nfolds, resdir, outdir, False)

def classify_weighted_voting(indicesdir, nfolds, resdir, outdir, applyweights=False):
    """Classify by voting. Weighting is provided as argument. If not provided,
    a flat voting is performed.

    Args:
    indicesdir(str): path to the indices and labels files
    nfolds(int): number of folds of the cross-validation
    resdir(str): results of the cross validation and alson the output dir
    applyweights(bool): apply weights store in results.log files

    """

    if not os.path.exists(outdir): os.mkdir(outdir)
    resultspath = os.path.join(outdir, 'results.log')
    resultsfh = open(resultspath, 'w')

    start = time()

    methpaths = load_methods_dirs(resdir, ['concatenated'])

    resultsfh.write('{} voting\n'.format('Weighted' if applyweights else 'Simple'))

    resultsfh.write('Number of features:\n')
    resultsfh.write('{}\n'.format(len(methpaths)))

    acc = np.ndarray([5,])
    weights = []
    if applyweights:
        for p in methpaths:
            respath = os.path.join(p, 'results.log')
            fh = open(respath)
            lines = fh.readlines()
            fh.close()
            weights.append(float(lines[10].split(',')[0].strip()))
    else:
        weights = np.ones((len(methpaths)))

    _, labels = load_indices_and_labels_crossvalidation(indicesdir, nfolds)

    tpsum = 0
    resultsfh.write('Number of hits, training and prediction time per fold:\n')
    samplesz = 0

    for f in range(nfolds):
        votes = []
        vallabels = labels[f]
        for methpath in methpaths:
            devaluesepath = os.path.join(methpath, 'decvalues_fold{}.csv'.format(f))
            decvalues = genfromtxt(devaluesepath, delimiter='\n')
            vote = np.ones(decvalues.shape, dtype=int)
            cginds = np.where(decvalues < 0)
            vote[cginds] = -1
            votes.append(vote)
        numrows = votes[0].shape[0]
        votessum = np.zeros(votes[0].shape)

        for j in range(len(votes)):
            votessum += votes[j] * weights[j]

        votingres = np.ones(votessum.shape, dtype=int)
        cginds = np.where(votessum < 0)
        votingres[cginds] = -1

        hits = np.equal(votingres, vallabels)
        tp = np.sum(hits)
        acc[f] = tp/votingres.shape[0]

        resultsfh.write('{}/{},0,0\n'.format(tp, votingres.shape[0]))
        tpsum += tp
        samplesz += votingres.shape[0]

    foldsvar = np.var(acc, ddof=1)
    resultsfh.write('Folds average accuracy and variance:\n')
    resultsfh.write('{},{}\n'.format(tpsum/samplesz, foldsvar))
    resultsfh.write('Overall time:\n')
    resultsfh.write('{}\n'.format(time() - start))
    resultsfh.write('SVM kernel and C param:\n')
    resultsfh.write('{},{}\n'.format(-1, -1))
    resultsfh.close()


def load_decvalues(methpaths, fold):
    """Load the decision values of generated by previous experiments

    Args:
    methpaths(list): each element contains the full path of a method result
    fold(int): fold of the cross-validation

    Returns:
    ndarray: each row contains the decision values of each method
    """

    auxpath = os.path.join(methpaths[0], 'decvalues_fold{}.csv'.format(fold))
    aux = genfromtxt(auxpath, delimiter='\n')
    nmethods = len(methpaths)
    features = np.ndarray((aux.shape[0], nmethods))

    for idx, d in enumerate(methpaths):
        decvaluespath = os.path.join(d, 'decvalues_fold{}.csv'.format(fold))
        decvalues = genfromtxt(decvaluespath, delimiter='\n')
        features[:, idx] = decvalues

    return features

def load_methods_dirs(resultsrootdir, exclude):
    """Load sorted elements in resultsrootdir/, excluding files and directories starting
    with '_'

    Args:
    resultsrootdir(str): root path
    exclude(list): list of folders to exclude

    Returns:
    list of str: Sorted list of directories
    """

    methpaths = []
    dirs = sorted(os.listdir(resultsrootdir))
    for d in dirs:
        if d.startswith('_'): continue
        if d in exclude: continue
        dirpath = os.path.join(resultsrootdir, d)
        if not os.path.isdir(dirpath): continue
        methpaths.append(dirpath)
    return methpaths

def classify_decision_values(indicesdir, nfolds, resdir, outdir):
    if not os.path.exists(outdir): os.mkdir(outdir)

    start = time()
    labels = {}

    methpaths = load_methods_dirs(resdir, ['concatenated'])
    resultspath = os.path.join(outdir, 'results.log')
    resultsfh = open(resultspath, 'w')
    resultsfh.write('Decision values classification\n')

    dirs = sorted(os.listdir(resdir))
    methpaths = load_methods_dirs(resdir, ['concatenated'])
    resultsfh.write('Number of features:\n')
    resultsfh.write('{}\n'.format(len(methpaths)))

    tpsum = 0
    resultsfh.write('Number of hits, training and prediction time per fold:\n')
    samplesz = 0

    ker = UNKNOWN_KERNEL_TYPE # Flag to compute grid search
    c = -1

    # For each fold, create the features set and the validation set
    acc = np.ndarray([5,])
    for k in range(nfolds):
        valfold = k
        trainfolds = list(range(nfolds)); trainfolds.remove(k)

        labelspath = os.path.join(indicesdir, 'labels_fold{}.csv'.format(k))
        labels[k] = genfromtxt(labelspath, dtype=int)

        vallabels = labels[k]
        valfeatures = load_decvalues(methpaths, k)

        trainlabels = np.array([])
        trainfeatures = np.ndarray((0, len(methpaths)))

        for kk in trainfolds:
            foldlabels = labels[k]
            trainlabels = np.concatenate((trainlabels, foldlabels), axis=0)
            
            foldfeatures = load_decvalues(methpaths, k)
            trainfeatures = np.concatenate((trainfeatures, foldfeatures), axis=0)

        tp, decvalues, traintime, predtime, c, ker = trainval(trainfeatures, trainlabels,
                                              valfeatures, vallabels, c, ker)

        decvaluespath = os.path.join(outdir, 'decvalues_fold{}.csv'.format(k))

        with open(decvaluespath, 'w') as fh2:
            for v in decvalues:
                fh2.write('{}\n'.format(v))
        resultsfh.write('{}/{},{},{}\n'.format(tp, valfeatures.shape[0], traintime, predtime))
        tpsum += tp
        samplesz += valfeatures.shape[0]
        acc[k] = tp/valfeatures.shape[0]

    #foldsvar = np.var(acc, ddof=1)
    resultsfh.write('Folds average accuracy and variance:\n')
    resultsfh.write('{},{}\n'.format(tpsum/samplesz, np.var(acc, ddof=1)))
    resultsfh.write('Overall time:\n')
    resultsfh.write('{}\n'.format(time() - start))
    resultsfh.write('SVM kernel and C param:\n')
    resultsfh.write('{},{}\n'.format(-1, -1))
    resultsfh.close()

def main_metaclassification(indicesdir, nfolds, resdir):
    simplevotingdir = os.path.join(resdir, '_simplevoting')
    weightedvotingdir = os.path.join(resdir, '_weightedvoting')
    decvaluesclassficationdir = os.path.join(resdir, '_decvaluesclassification')

    classify_simple_voting(indicesdir, nfolds, resdir, simplevotingdir)
    classify_weighted_voting(indicesdir, nfolds, resdir, weightedvotingdir, True)
    classify_decision_values(indicesdir, nfolds, resdir, decvaluesclassficationdir)

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--featuresdir', help='Path to the features folder')
    parser.add_argument('--indicesdir', help='Path to the indices/labels folder')
    parser.add_argument('--outdir', help='Output directory')
    parser.add_argument('--nfolds', help='Number of the folds in the cross-validation',
                        default=5, type=int)
    parser.add_argument('--overwrite', help='Overwrite existing folders',
                        action='store_true')
    nprocs = 7

    args = parser.parse_args()
    if None in (vars(args)).values():
        print(parser.description)
        print(parser.usage)
        return

    if os.path.exists(args.outdir) and not args.overwrite:
        print('{} exists. Add --overwrite'.format(args.outdir))
        return

    featuresdir, indicesdir, outdir = map(expanduser,
                                          [args.featuresdir,
                                           args.indicesdir,
                                           args.outdir])

    main_classification(featuresdir, indicesdir, outdir, nprocs)
    #main_metaclassification(indicesdir, args.nfolds, outdir)

if __name__ == "__main__":
    main()


