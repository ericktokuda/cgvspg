/* This routine is copied from Wavelab850 */

void mirrorfilt(lpf,hpf,length)
double *lpf, *hpf;
int    length;
{
    int i,isign;
	isign = 1;
	for(i=0; i < length; i++){
	    *hpf++ = isign * *lpf++;
		isign *= -1;
	}
}
