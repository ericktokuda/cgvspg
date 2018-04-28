/* Resampling along the column (Type 1 and 2)
 *
 * Created by: Minh N. Do, March 2000
 */



#include "mex.h"
#include "math.h"


/*
  function y = resample1(x, type, shift, extmod)
  % RESAMPLE1	Resampling along the column
  %
  %	y = resampc(x, type, shift, extmod)
  %
  % Input:
/  %	x:	image that is extendable along the column direction
  %	type:	either 1 or 2 (1 for shuffering down and 2 for up)
  %	shift:	amount of shifts (typically 1)
  %     extmod: extension mode:
  %		'per' 	periodic
  %		'ref1'	reflect about the edge pixels
  %		'ref2'	reflect, doubling the edge pixels 
  %
  % Output:
  %	y:	resampled image with:
  %		R1 = [1, shift; 0, 1] or R2 = [1, -shift; 0, 1]
*/
void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double *x, *px;		/* input matrix and pointer */
    double *y, *py;		/* result matrix and pointer */
    double type;			/* type of resampling */
    double s,j;			/* amount of shifts */
    char extmod[10];		/* extension mode */

    int a, i, k, m, n;

    /* Parse input */
    if (nrhs < 4)
	mexErrMsgTxt("Not enough input for RESAMPLE1!");

    x = mxGetPr(prhs[0]);
    m = mxGetM(prhs[0]);
    n = mxGetN(prhs[0]);

    type = (int) mxGetPr(prhs[1])[0];
    if ((type != 1) && (type != 2))
	mexErrMsgTxt("The second input (type) must be either 1 or 2");

    s = (double) mxGetPr(prhs[2])[0];

    if (!mxIsChar(prhs[3]))
	mexErrMsgTxt("EXTMOD arg must be a string");

    mxGetString(prhs[3], extmod, 10);
    
    /* Create output */
    plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    y = mxGetPr(plhs[0]);

    px = x;
    py = y;

    if (strcmp(extmod, "per") == 0)
    {
	/* Resampling column-wise:
	 * 		y[i, j] = x[<i+sj>, j] 	if type == 1
	 * 		y[i, j] = x[<i-sj>, j] 	if type == 2
	 */
	for (j = 0; j < n; j++)
	{
	    /* Circular shift in each column */
        a = floor(s * j);
        if (type == 1)
		k = a%m;
	    else
		k = -a%m;
	    
	    /* Convert to non-negative mod if needed */
	    if (k < 0)
		k += m;
	    
	    for (i = 0; i < m; i++)
	    {
		if (k >= m)
		    k -= m;
		
		py[i] = px[k];
		
		k++;
	    }
	    
	    px += m;
	    py += m;
	}
    }

    else
	mexErrMsgTxt("Invalid EXTMOD");
}



