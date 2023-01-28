#ifndef __edge_canny_detector_h__
#define __edge_canny_detector_h__

#include "ap_int.h"
#include "hls_stream.h"
#include "ap_axi_sdata.h"

#include "common/xf_common.hpp"
#include "common/xf_infra.hpp"
#include "common/xf_utility.hpp"

#include "imgproc/xf_canny.hpp"
#include "imgproc/xf_cvt_color.hpp"

typedef ap_axiu<24,1,1,1> pixel; 
typedef hls::stream<pixel> pixel_t ;

#define IMG_MAX_ROWS 720
#define IMG_MAX_COLS 1280
#define FILTER_TYPE 3

void edge_canny_detector(pixel_t &src,pixel_t &dst,ap_int<32> lowthreshold,ap_int<32> highthreshold);

#endif
