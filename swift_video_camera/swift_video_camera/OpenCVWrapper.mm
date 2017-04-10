#import "OpenCVWrapper.h"
#import <opencv2/opencv.hpp>
//#import <opencv2/highgui/ios.h>

//@implementation OpenCVWrapper
//
//
//+(NSString *) openCVVersionString
//{
//    return [NSString stringWithFormat: @"openCV Version %s", CV_VERSION];
//}
//
//
//+(UIImage * ) makeGrayFromImage:(UIImage *)image
//{
//    // transform UIImagge to cv::Mat
//    cv::Mat imageMat;
//    UIImageToMat(image, imageMat);
//    
//    // if the image already grayscale, return it
//    if(imageMat.channels() == 1)return image;
//    
//    // transform the cv::Mat color image to gray
//    cv::Mat grayMat;
//    cv::cvtColor (imageMat, grayMat, CV_BGR2GRAY);
//    
//    return MatToUIImage(grayMat);
//}
//
@end
