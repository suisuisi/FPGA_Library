#include <stdint.h>

#define IMAGE_ROWS 242
#define IMAGE_COLUMNS 308
#define PADDED_IMG_ROWS (IMAGE_ROWS + 2)
#define PADDED_IMG_COLS (IMAGE_COLUMNS + 2)
#define WindowSize 3
#define Window_Array_Size 9

typedef uint8_t PIXEL_VAL_T;
typedef PIXEL_VAL_T IMG_ARR_T[IMAGE_ROWS][IMAGE_COLUMNS];
typedef PIXEL_VAL_T PADDED_IMG_ARR_T[PADDED_IMG_ROWS][PADDED_IMG_COLS];

void TwoD_MedianFilter(IMG_ARR_T Image_with_Noise, IMG_ARR_T Filtered_Image);
void CSV_Import(IMG_ARR_T Image_with_Noise, char filename[]);
void Zeros(PIXEL_VAL_T X[PADDED_IMG_ROWS][PADDED_IMG_COLS]);
void Sort(PIXEL_VAL_T Window_Array[Window_Array_Size]);
void ZeroPad(IMG_ARR_T Image_with_Noise, PADDED_IMG_ARR_T Padded_Image);
void Window_and_Sort(PADDED_IMG_ARR_T Padded_Image, IMG_ARR_T Filtered_Image);
void Validate_output(IMG_ARR_T Actual, IMG_ARR_T Expected);
