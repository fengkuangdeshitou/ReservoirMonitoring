//
//  BaseViewController+BarButtonItem.m
//  ReservoirMonitoring
//
//  Created by 王帅 on 2022/4/11.
//

#import "BaseViewController+BarButtonItem.h"

@implementation BaseViewController (BarButtonItem)

- (void)setLeftBatButtonItemWithImage:(UIImage *)image
                                  sel:(nullable SEL)sel{
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:self action:sel];
    self.navigationItem.leftBarButtonItem = item;
}

@end
