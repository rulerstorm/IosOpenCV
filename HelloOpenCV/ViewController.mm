//
//  ViewController.m
//  test
//
//  Created by Ruler on 14-10-14.
//  Copyright (c) 2014年 Ruler. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UIScrollViewDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImagePickerController * iPC;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

@implementation ViewController 
- (IBAction)getImageFromLibrary{
    
    self.iPC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:self.iPC animated:YES completion:nil];
}

- (IBAction)getImageFromCamera{
    
    self.iPC.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:self.iPC animated:YES completion:nil];
}




- (void)viewDidLoad {
    [super viewDidLoad];
    
    //设置图片抓取器
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    [imagePickerController setDelegate:self];
    self.iPC = imagePickerController;
    
    // 设置最大和最小的缩放比例
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.minimumZoomScale = 0.2;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *newImage = [info valueForKey:UIImagePickerControllerOriginalImage];
    self.imageView.image = newImage;
    //关闭picker
    [self dismissViewControllerAnimated:YES completion:NULL];
    //设置图片缩放器属性
    self.scrollView.contentSize = newImage.size;
}


#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    return;
}



#pragma 抠图

- (IBAction)kouTuPressed:(id)sender {

    Mat I = [self cvMatFromUIImage:self.imageView.image];
//    
//    Mat gray = Mat(I.size(),CV_8UC1);
//    Mat color_boost = Mat(I.size(),CV_8UC3);
//    
//    decolor(I,gray,color_boost);
//    
//    UIImage *tempImage = [self UIImageFromCVMat:gray];
//    
//    self.imageView.image = tempImage;

    Mat gray;
    cvtColor(I, gray, CV_BGR2GRAY);
    UIImage *tempImage = [self UIImageFromCVMat:gray];
    self.imageView.image = tempImage;
}


- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}


- (cv::Mat)cvMatGrayFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC1); // 8 bits per component, 1 channels
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}

-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end

