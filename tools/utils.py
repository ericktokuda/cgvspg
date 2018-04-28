#!/usr/bin/env python3
"""Utilities

"""

import os
import numpy as np
import subprocess as subpr
import logging

def filter(inputstr):
    """ Trim last character and replace NaN,Inf by a high value (1000)
    """
    _str = inputstr[0][:-1]
    return _str.replace('NaN', '2147483647').replace('Inf', '2147483647') #MAX INT32

def filter_and_concat_recursive(rootdir, outdir):
    """It assuems the following structure
    CG
    ├ methods
    ...
    PG
    ├ methods
    ...
    """
    cgpath = os.path.join(rootdir, 'CG')
    pgpath = os.path.join(rootdir, 'PG')

    meths = os.listdir(cgpath)
    concatenatedcg = []
    if not os.path.isdir(outdir): os.makedirs(outdir)

    for meth in meths:
        cgmethpath = os.path.join(cgpath, meth)
        if not os.path.isdir(cgmethpath): continue
        logging.debug(cgmethpath)
        pgmethpath = os.path.join(pgpath, meth)
        cgfeat = filter_and_concat(cgmethpath)
        pgfeat = filter_and_concat(pgmethpath)
        fh = open(os.path.join(outdir, meth + '.csv'), 'w')
        fh.write(cgfeat)
        fh.write(pgfeat)
        fh.close()

def filter_and_concat(filesdir, out=None):
    if out: outfh = open(out, 'w')
    outstr = ''

    for f in os.listdir(filesdir):
        filepath = os.path.join(filesdir, f)
        with open(filepath) as fh:
            aux = fh.readlines()
        feats = filter(aux) + '\n'
        outstr += feats
        if out: outfh.write(feats)

    if out: outfh.close()
    return outstr

def get_files_labels(datasetdir):
    """ Assume the following hierarchy:
     datasetdir
       ├─CG
         └─images
       └─PG
         └─images
    """

    ids = {}
    names = {}
    labels = {}
    _id = 0

    classid = -1

    for d in os.listdir(datasetdir):
        _dir = os.path.join(datasetdir, d)
        for img in os.listdir(_dir):
            if not img.endswith('.jpg'): continue
            aux = img.split('.')
            imgname = ''.join(aux[:-1])
            ids[imgname] = _id
            names[_id] = imgname
            labels[_id] = classid
            _id += 1

        classid += 2
    return ids, names, labels

def convert_folds_list(foldpath, ids, labels):
    retids = []
    retlabels = []
    fh = open(foldpath)

    for l in fh:
        aux = l.strip().split('.')
        imgname = ''.join(aux[:-1])
        _id = ids[imgname]
        retids.append(_id)
        retlabels.append(labels[_id])
    fh.close()
    return retids, retlabels


def batch_concatenate(rootpath):
    # Assume the following hierarchy:
    # rootpath
    #   ├─CG
    #   └─PG
    #     ├─method1
    #     ├─method2 ...

    for _class in [ 'CG', 'PG']:
        classpath = os.path.join(rootpath, _class)
        for meth in os.listdir(classpath):
            methpath = os.path.join(classpath, meth)
            if not os.path.isdir(methpath): continue
            outpath = os.path.join(rootpath, meth + '_' + _class + '.csv')
            filter_and_concat(methpath, outpath)

def check_nfields_consistency(filesdir):
    files = os.listdir(filesdir)

    with open(os.path.join(filesdir, files[0])) as fh:
        content = fh.readlines()
    refnfields = content[0].count(',')
    print('Reference number of fields ({}): {}'.format(files[0],
                                                       refnfields))

    ndiff = 0
    diffids = []
    _id = 0
    for f in files:
        _id += 1
        fullfile = os.path.join(filesdir, f)
        with open(fullfile) as fh:
            content = fh.readlines()
        nfields = content[0].count(',')
        if nfields != refnfields:
            print('{} contains {} fields. Exiting.'.format(fullfile, nfields))
            #ndiff += 1
            #diffids.append(_id)
            return
    print('{} files with different number of fields'.format(ndiff))
    #print('Different ids {}'.format(diffids))
    print('No inconsistency found.')

def check_nfields_consistency_recursive(filesdir):
    folders = os.listdir(filesdir)

    for d in folders:
        _dir = os.path.join(filesdir, d)
        if not os.path.isdir(_dir): continue
        print('##########################################################')
        print(_dir)
        check_nfields_consistency(_dir)


def batch_convert_folds(datasetpath, foldspath, outpath):
    """Convert all folds to consider images as ids, which order is given
    by os.listdir()

    Args:
    datasetpath: Dataset path
    foldspath: directory containing the lists
    outpath: output directory path

    """

    ids, names, labels = get_files_labels(datasetpath)
    for i in range(5):
        foldpath = os.path.join(foldspath, 'Fold{}.txt'.format(i))
        convertedids, convertedlabels = convert_folds_list(foldpath, ids,
                                                           labels)
        with open(os.path.join(outpath, 'ids_fold{}.txt'.format(i)), 'w') as fh:
            fh.write('\n'.join(str(entry) for entry in convertedids))

        outlabels = os.path.join(outpath, 'labels_fold{}.txt'.format(i))
        with open(outlabels, 'w') as fh:
            fh.write('\n'.join(str(entry) for entry in convertedlabels))

def cbind_csvs_from_dir(csvsdir, outpath=None):
    files = os.listdir(csvsdir)

    for i in range(len(files)):
        f = files[i]
        if not f.endswith('.csv'): continue
        csvpath = os.path.join(csvsdir, f)
        concatenated = np.genfromtxt(csvpath, delimiter=',')
        print('Concatenating {}'.format(f))
        break

    for f in files[i+1:]:
        if not f.endswith('.csv'): continue
        csvpath = os.path.join(csvsdir, f)
        featuresset = np.genfromtxt(csvpath, delimiter=',')
        concatenated = np.concatenate((concatenated, featuresset), axis=1)
        print('{}'.format(f))
        print(concatenated.shape)

    if outpath:
        np.savetxt(os.path.join(outpath, 'concatenated.csv'), concatenated, delimiter=",")

    return concatenated

def check_absent(csvdir, imgsdir, ext):
    for _file in os.listdir(csvdir):
        aux = _file.split('.')[0] + ext
        imgfile = os.path.join(imgsdir, aux)
        if not os.path.exists(imgfile):
            #print(imgfile)
            print(os.path.join(csvdir, _file))
        #if os.path.exists()

def convert_indices(indicespath):
    f0 = []
    f1 = []
    f2 = []
    f3 = []
    f4 = []

    with open(indicespath) as fh:
        for l in fh:
            fields = l.strip().split('\t')
            f0.append(fields[0])
            f1.append(fields[1])
            f2.append(fields[2])
            f3.append(fields[3])
            f4.append(fields[4])
            #print(l)
    with open('/tmp/old_fold0.csv', 'w') as fh:
        fh.write('\n'.join(f0))
    with open('/tmp/old_fold1.csv', 'w') as fh:
        fh.write('\n'.join(f1))
    with open('/tmp/old_fold2.csv', 'w') as fh:
        fh.write('\n'.join(f2))
    with open('/tmp/old_fold3.csv', 'w') as fh:
        fh.write('\n'.join(f3))
    with open('/tmp/old_fold4.csv', 'w') as fh:
        fh.write('\n'.join(f4))

def compile_results(resdir):
    avgaccs = {}
    vars = {}
    print('Method,Avg. acc.,Variance')
    for d in os.listdir(resdir):
        resultspath = os.path.join(resdir, d, 'results.log')
        if not os.path.exists(resultspath): continue
        resultsfh = open(resultspath)
        lines = resultsfh.readlines()

        acc = np.ndarray([5,])
        for j in range(5):
            hits = lines[4+j].strip().split(',')[0].split('/')[0]
            total = lines[4+j].strip().split(',')[0].split('/')[1]
            acc[j] = float(hits)/float(total)

        
        vars[d] = np.var(acc, ddof=1)
        avgaccs[d] = float(lines[-3].strip())
        print('{},{},{}'.format(d, avgaccs[d], vars[d]))
        resultsfh.close()
    return avgaccs, vars

def convert_256_rgb(inpath, outpath=None):
    if not os.path.exists(inpath):
        print('{} does not exist.'.format(inpath))
        return False

    if not outpath: outpath = inpath
    if os.path.isdir(inpath):
        curdir = os.getcwd()
        os.chdir(inpath)
        cmd = 'mogrify -resize 256x256! {} -colorspace sRGB -type TrueColor -path {} *.jpg'.format(inpath, outpath)
    else:
        cmd = 'convert -resize 256x256! -colorspace sRGB -type TrueColor {} {}'.format(inpath, outpath)
    pr = subpr.Popen(cmd.split())
    (_stdin, _stderr) = pr.communicate()
    return True

def main():
    logging.basicConfig(level=logging.DEBUG)
    #convert_256_rgb('/tmp/', '/tmp/bu')
    #convert_256_rgb('/home/frodo/datasets/cgvspg/jpeg-compression-70/CG', '/home/frodo/datasets/cgvspg/jpeg-compression-70_256/CG')
    #convert_256_rgb('/home/frodo/datasets/cgvspg/jpeg-compression-70/PG', '/home/frodo/datasets/cgvspg/jpeg-compression-70_256/PG')
    filter_and_concat_recursive('/home/keiji/temp/20180125-features_jpeg-compression-70_256/', '/home/keiji/temp/20180125-features_jpeg-compression-70_256/')
    concatenated = cbind_csvs_from_dir('/home/keiji/temp/20180125-features_jpeg-compression-70_256/', '/home/keiji/temp/20180125-features_jpeg-compression-70_256/')
    #resize_imagemagick('/tmp/out.jpg', '/tmp/out.jpg')
    #resdir = '/home/frodo/temp/20180120-cgvspgresults/'
    #res = compile_results(resdir)
    #print(res)
    #csvsdir = '/home/frodo/projects/cgvspg/data/16396/features/'
    #concatenated = cbind_csvs_from_dir(csvsdir)
    #np.savetxt(os.path.join(csvsdir, 'concatenated.csv'), concatenated, delimiter=",")

    #print(concatenated.shape)

    #datasetpath = '/home/frodo/datasets/DSTokExt_256/'
    #foldspath = '/home/frodo/projects/cgvspg/data/'
    #outpath = '/tmp'
    #batch_convert_folds(datasetpath, foldspath, outpath)
    #check_nfields_consistency('/home/frodo/temp/20180115-outcgvspg/PG/popescu')
    #check_nfields_consistency_recursive('/home/frodo/temp/20180115-outcgvspg/CG/')
    #check_nfields_consistency_recursive('/home/frodo/temp/20180115-outcgvspg/PG/')
    #filter_and_concat(commonpath + '/CG/boxcount/', '/tmp/out.csv')
    #batch_concatenate('/home/frodo/temp/20180115-outcgvspg/')
    #labels = get_files_labels('/home/frodo/datasets/DSTokExt_256/')
    #print(labels)

if __name__ == "__main__":
    main()

