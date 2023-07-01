#include "MedianFilter.h"
#include <stdio.h>


//Below Function will call the multiple functions
void TwoD_MedianFilter(IMG_ARR_T Image_with_Noise, IMG_ARR_T Filtered_Image) {

  PADDED_IMG_ARR_T Padded_Image;

  ZeroPad(Image_with_Noise, Padded_Image);

  Window_and_Sort(Padded_Image, Filtered_Image);

}

//Below function will create zeros for the given dimensions of the matrix
void Zeros(PIXEL_VAL_T X[PADDED_IMG_ROWS][PADDED_IMG_COLS]) {

  Zeros_label9:for (int i = 0; i < PADDED_IMG_ROWS; ++i) {
   Zeros_label10:for (int j = 0; j < PADDED_IMG_COLS; ++j) {
      X[i][j] = 0;
    }
  }
}

//Below function will insert the noise data in the zero padded matrix
void ZeroPad(IMG_ARR_T Image_with_Noise, PADDED_IMG_ARR_T Padded_Image) {

  Zeros(Padded_Image);

  for (int i = 0; i < IMAGE_ROWS; i++) {
   for (int j = 0; j < IMAGE_COLUMNS; j++) {
      Padded_Image[i + 1][j + 1] = Image_with_Noise[i][j];
    }
  }

}

//Below function will sort a window size 3X3
void Sort(PIXEL_VAL_T Window_Array[Window_Array_Size]) {
  PIXEL_VAL_T temp = 0;

 for (int i = 0; i < Window_Array_Size; i++) {
  Sort_label2:for (int j = i + 1; j < Window_Array_Size; j++) {
      if (Window_Array[j] < Window_Array[i]) {
        temp = Window_Array[i];
        Window_Array[i] = Window_Array[j];
        Window_Array[j] = temp;
      }
    }
  }
}

//Below function will take the Padded matrix and replaces the median by calling the sort function
//After sorting all the rows and cols will get filtered
void Window_and_Sort(PADDED_IMG_ARR_T Padded_Image, IMG_ARR_T Filtered_Image) {

for (int i = 0; i < IMAGE_ROWS; i++) {
  for (int j = 0; j < IMAGE_COLUMNS; j++) {
      PIXEL_VAL_T Window[Window_Array_Size];
      int inc = 0;
      for (int X = 0; X < WindowSize; X++) {
     Window_and_Sort_label33:for (int Y = 0; Y < WindowSize; Y++) {
          Window[inc] = Padded_Image[i + X][j + Y];
          inc++;
        }
      }
      Sort(Window);
      Filtered_Image[i][j] = Window[4];
    }
  }

}




