#include "edge_canny_detector.h"

void ExtractPixel(XF_TNAME(XF_8UC3,XF_NPPC1)&src,ap_uint<8>src_value[3])
{
#pragma HLS INLINE off
	unsigned int i,j=0;
	for(i=0;i<24;i+=8)
	{
#pragma HLS UNROLL
		src_value[j]=src.range(i+7,i);
		j++;
	}
}

template<int ROWS,int COLS>
void xfrgb2gray(xf::cv::Mat<XF_8UC3,ROWS,COLS,XF_NPPC1> &src,xf::cv::Mat<XF_8UC1,ROWS,COLS,XF_NPPC1> &dst)
{
	XF_TNAME(XF_8UC3,XF_NPPC1)rgb_packed;
	XF_TNAME(XF_8UC1,XF_NPPC1)gray_packed;
	ap_uint<8>rgb[3];
	ap_uint<8>gray;
	unsigned int i,j=0;
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
#pragma HLS PIPELINE
			rgb_packed=src.read(i*COLS+j);
			ExtractPixel(rgb_packed,rgb);
			gray=CalculateGRAY(rgb[0],rgb[1],rgb[2]);
			gray_packed.range(7,0)=gray;
			dst.write(i*COLS+j,gray_packed);
		}
	}
}

template<int ROWS,int COLS>
void AddWeightedKernel(xf::cv::Mat<XF_8UC1,ROWS,COLS,XF_NPPC1>&src1,
					   float alpha,
					   xf::cv::Mat<XF_8UC1,ROWS,COLS,XF_NPPC1>&src2,
					   float beta,
					   float gamma,
					   xf::cv::Mat<XF_8UC1,ROWS,COLS,XF_NPPC1>&dst
					)
{
	ap_fixed<16,8,AP_RND>value_src1=alpha;
	ap_fixed<16,8,AP_RND>value_src2=beta;
	ap_fixed<16,8,AP_RND>value_src3=gamma;
	XF_TNAME(XF_8UC1,XF_NPPC1)pixel1;
	XF_TNAME(XF_8UC1,XF_NPPC1)pixel2;
	XF_TNAME(XF_8UC1,XF_NPPC1)pixel3;
	ap_int<24>firstcmp;
	ap_int<24>secondcmp;
	ap_int<16>thirdcmp;
	ap_uint<8>value;
	ap_uint<8>value_cmp1;
	ap_uint<8>value_cmp2;
	unsigned int i,j=0;
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
#pragma HLS pipeline
			pixel1=src1.read(i*COLS+j);
			pixel2=src2.read(i*COLS+j);
			value_cmp1=pixel1.range(7,0);
			value_cmp2=pixel2.range(7,0);
			firstcmp=(ap_int<24>)value_cmp1*value_src1;
			secondcmp=(ap_int<24>)value_cmp2*value_src2;
			thirdcmp=(ap_int<16>)firstcmp+secondcmp+value_src3;
			if(thirdcmp>255)
			{
				thirdcmp=255;
			}
			else if(thirdcmp<0)
			{
				thirdcmp=0;
			}
			value=thirdcmp;
			pixel3.range(7,0)=value;
			dst.write(i*COLS+j,pixel3);
		}
	}
}

template<int ROWS,int COLS>
void xfgray2rgb(xf::cv::Mat<XF_8UC1,ROWS,COLS,XF_NPPC1> &src,xf::cv::Mat<XF_8UC3,ROWS,COLS,XF_NPPC1> &dst)
{
#pragma HLS INLINE off
	XF_TNAME(XF_8UC3,XF_NPPC1)rgb_packed;
	XF_TNAME(XF_8UC1,XF_NPPC1)gray_packed;
	ap_uint<8>rgb[3];
	ap_uint<8>gray;
	unsigned i,j,k=0;
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
#pragma HLS PIPELINE
			gray_packed=src.read(i*COLS+j);
			gray=gray_packed.range(7,0);
			rgb_packed.range(7,0)=gray;
			rgb_packed.range(15,8)=gray;
			rgb_packed.range(23,16)=gray;
			dst.write(i*COLS+j,rgb_packed);
		}
	}
}

template<int ROWS,int COLS>
void duplicate(xf::cv::Mat<XF_16SC1,ROWS,COLS,XF_NPPC1>&src1,xf::cv::Mat<XF_16SC1,ROWS,COLS,XF_NPPC1>&src2,xf::cv::Mat<XF_16SC1,ROWS,COLS,XF_NPPC1> &dst1,xf::cv::Mat<XF_16SC1,ROWS,COLS,XF_NPPC1> &dst2,xf::cv::Mat<XF_16SC1,ROWS,COLS,XF_NPPC1> &dst3,xf::cv::Mat<XF_16SC1,ROWS,COLS,XF_NPPC1> &dst4)
{
	XF_TNAME(XF_16SC1,XF_NPPC1)pixel_src1;
	XF_TNAME(XF_16SC1,XF_NPPC1)pixel_src2;
	unsigned int i,j=0;
	for(i=0;i<ROWS;i++)
	{
		for(j=0;j<COLS;j++)
		{
#pragma HLS PIPELINE
			pixel_src1=src1.read(i*COLS+j);
			pixel_src2=src2.read(i*COLS+j);
			dst1.write(i*COLS+j,pixel_src1);
			dst2.write(i*COLS+j,pixel_src1);
			dst3.write(i*COLS+j,pixel_src2);
			dst4.write(i*COLS+j,pixel_src2);
		}
	}
}

void edge_canny_detector(pixel_t &src,pixel_t &dst,ap_int<8>&lowthreshold,ap_int<8>&highthreshold)
{

#pragma HLS INTERFACE ap_ctrl_none port=return
#pragma HLS INTERFACE ap_vld port=highthreshold register
#pragma HLS INTERFACE ap_vld port=lowthreshold register
#pragma HLS INTERFACE axis port=dst register_mode=both depth=16 register
#pragma HLS INTERFACE axis port=src register_mode=both depth=16 register
#pragma HLS DATAFLOW
	xf::cv::Mat<XF_8UC3,IMG_MAX_ROWS,IMG_MAX_COLS,XF_NPPC1>rgb_img_src;
#pragma HLS STREAM variable=rgb_img_src.data //depth=1280 dim=1
	xf::cv::Mat<XF_8UC1,IMG_MAX_ROWS,IMG_MAX_COLS,XF_NPPC1>gray_img_src;
#pragma HLS STREAM variable=gray_img_src.data //depth=1280 dim=1
	xf::cv::Mat<XF_8UC1,IMG_MAX_ROWS,IMG_MAX_COLS,XF_NPPC1>gray_img_dst;
#pragma HLS STREAM variable=gray_img_dst.data //depth=1280 dim=1
	xf::cv::Mat<XF_8UC3,IMG_MAX_ROWS,IMG_MAX_COLS,XF_NPPC1>rgb_img_dst;
#pragma HLS STREAM variable=rgb_img_dst.data //depth=1280 dim=1

	int img_height=rgb_img_src.rows;
	int img_width=rgb_img_src.cols;
    xf::cv::Mat<XF_8UC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> gaussian_mat(img_height, img_width);
#pragma HLS STREAM variable=gaussian_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> gradx_mat(img_height, img_width);
#pragma HLS STREAM variable=gradx_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> gradx1_mat(img_height, img_width);
#pragma HLS STREAM variable=gradx1_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> gradx2_mat(img_height, img_width);
#pragma HLS STREAM variable=gradx2_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1,IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> grady_mat(img_height, img_width);
#pragma HLS STREAM variable=grady_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> grady1_mat(img_height, img_width);
#pragma HLS STREAM variable=grady1_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> grady2_mat(img_height, img_width);
#pragma HLS STREAM variable=grady2_mat.data //depth=1280 dim=1
    xf::cv::Mat<XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1, 1280*3> magnitude_mat(img_height, img_width);
#pragma HLS STREAM variable=magnitude_mat.data //depth=5760 dim=1
    xf::cv::Mat<XF_8UC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1, 1280*3> phase_mat(img_height, img_width);
#pragma HLS STREAM variable=phase_mat.data //depth=5760 dim=1
    xf::cv::Mat<XF_8UC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1> nms_mat(img_height, img_width);
#pragma HLS STREAM variable=nms_mat.data //depth=1280 dim=1

// clang-format off
// clang-format on

// clang-format off

    // clang-format on

	xf::cv::AXIvideo2xfMat(src,rgb_img_src);
	xfrgb2gray<IMG_MAX_ROWS,IMG_MAX_COLS>(rgb_img_src,gray_img_src);
    xFAverageGaussianMask3x3<XF_8UC1, XF_8UC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_DEPTH(XF_8UC1,XF_NPPC1), XF_NPPC1, XF_WORDWIDTH(XF_8UC1,XF_NPPC1), (IMG_MAX_COLS >> XF_BITSHIFT(XF_NPPC1))>(
           gray_img_src, gaussian_mat, img_height, img_width);
    xFSobel<XF_8UC1, XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_DEPTH(XF_8UC1,XF_NPPC1), XF_DEPTH(XF_16SC1,XF_NPPC1),XF_NPPC1,XF_WORDWIDTH(XF_8UC1,XF_NPPC1), XF_WORDWIDTH(XF_16SC1,XF_NPPC1), 3, false>(
        gaussian_mat, gradx_mat, grady_mat, XF_BORDER_REPLICATE, img_height, img_width);
    duplicate<IMG_MAX_ROWS,IMG_MAX_COLS>(gradx_mat,grady_mat,gradx1_mat,gradx2_mat,grady1_mat,grady2_mat);
    xf::cv::magnitude<1, XF_16SC1,XF_16SC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_NPPC1, 1280*3>(gradx1_mat, grady1_mat, magnitude_mat);
    xFAngle<XF_16SC1, XF_8UC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_16SP, XF_8UP, XF_NPPC1, XF_16UW, XF_8UW, 1280*3>(
          gradx2_mat, grady2_mat, phase_mat, img_height, img_width);
    xFSuppression3x3<XF_16SC1, XF_8UC1, XF_8UC1, IMG_MAX_ROWS, IMG_MAX_COLS, XF_16SP, XF_8UP, XF_8UP, XF_NPPC1, XF_16UW, XF_8UW, XF_8UW,
                        (IMG_MAX_COLS >> XF_BITSHIFT(XF_NPPC1)), 1280*3, 1280*3>(magnitude_mat, phase_mat, nms_mat, lowthreshold,
                                                              highthreshold, img_height, img_width);
//    nPackNMS<IMG_MAX_ROWS,IMG_MAX_COLS>(nms_mat,gray_img_dst);

//    AddWeightedKernel<IMG_MAX_ROWS,IMG_MAX_COLS>(gradx_mat,0.5f,grady_mat,0.5f,0.0f,gray_img_dst);
	xfgray2rgb<IMG_MAX_ROWS,IMG_MAX_COLS>(nms_mat,rgb_img_dst);
	xf::cv::xfMat2AXIvideo(rgb_img_dst,dst);
}
