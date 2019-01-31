#include <string.h>
#include <stdio.h>
#include "fitsio.h"


/* ripe-fieldstat developed specifically for analysis of ringo2/3 skypolarisation flats 
 * Doug Arnold Sept 2012
 */

int main(int argc, char *argv[])
{
    fitsfile *fptr;  /* FITS file pointer */
    int status = 0;  /* CFITSIO status value MUST be initialized to zero! */
    int hdutype, naxis, ii, reg_y, reg_x, x_low, x_hi, y_low, y_hi;
    long naxes[2], totpix, fpixel[2];
    double *pix, sum = 0., meanval = 0., minval = 1.E33, maxval = -1.E33;
    char file[40], append[20];

    if (argc != 2) { 
      printf("Usage: ripe-imstat image \n");
      printf("\n");
      printf("Split the 512x512 pixel image into 100 50x50 pixel sections (with 6 pixel border) and print out the stats of each region into a extractor output format, ready for the ripe pipline to load into the ripe database.\n");
      printf("\n");
 
      return(0);
    }

    
    /* Print out header file info as per sextractor output */
    printf("# Output of ripe-imstat in a sextractor format for ripe to chomp on.\n");
    
     for (reg_x = 0; reg_x <= 99; reg_x++)
      {
	
	  x_low = 7 + ( (reg_x) * 5);
	  x_hi = x_low + 4;
	
	for (reg_y = 0; reg_y <= 99; reg_y++)
	{
    
	  y_low = 7 + ( (reg_y) * 5);
	  y_hi = y_low + 4;
    
  //  printf("Region\t%d\t%d\t[%d:%d,%d:%d]\n", reg_x, reg_y, x_low, x_hi, y_low, y_hi);
   
    sprintf(append,"[%d:%d,%d:%d]",x_low, x_hi, y_low, y_hi);
    sprintf(file,"%s%s", argv[1], append);
    
    //printf("%s\n", file);
    
    
    if ( !fits_open_image(&fptr, file, READONLY, &status) )
    {
      if (fits_get_hdu_type(fptr, &hdutype, &status) || hdutype != IMAGE_HDU) { 
        printf("Error: this program only works on images, not tables\n");
        return(1);
      }

      fits_get_img_dim(fptr, &naxis, &status);
      fits_get_img_size(fptr, 2, naxes, &status);

      if (status || naxis != 2) { 
        printf("Error: NAXIS = %d.  Only 2-D images are supported.\n", naxis);
        return(1);
      }

      pix = (double *) malloc(naxes[0] * sizeof(double)); /* memory for 1 row */

      if (pix == NULL) {
        printf("Memory allocation error\n");
        return(1);
      }

      totpix = naxes[0] * naxes[1];
      fpixel[0] = 1;  /* read starting with first pixel in each row */

      /* process image one row at a time; increment row # in each loop */
      for (fpixel[1] = 1; fpixel[1] <= naxes[1]; fpixel[1]++)
      {  
         /* give starting pixel coordinate and number of pixels to read */
         if (fits_read_pix(fptr, TDOUBLE, fpixel, naxes[0],0, pix,0, &status))
            break;   /* jump out of loop on error */

         for (ii = 0; ii < naxes[0]; ii++) {
           sum += pix[ii];                      /* accumlate sum */
           if (pix[ii] < minval) minval = pix[ii];  /* find min and  */
           if (pix[ii] > maxval) maxval = pix[ii];  /* max values    */
         }
      }
      
      free(pix);
      fits_close_file(fptr, &status);
    }

    if (status)  {
        fits_report_error(stderr, status); /* print any error message */
    } else {
        if (totpix > 0) meanval = sum / totpix;

        printf("%d\t%d\t%g\t0\t0\t0\t0\n", x_low+2, y_low+2, meanval);

    }
    // Reset values after printing line.
    sum = 0., meanval = 0., minval = 1.E33, maxval = -1.E33;
    
	}


}
    return(status);

}