//
//  RSPhotosViewModel.h
//  FlickrPhotos
//
//  Created by Ramsundar Shandilya on 17/07/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RSPhotosViewModel : NSObject

@property (nonatomic, strong) NSMutableArray *photosArray;

- (void)updatePhotos;

@end
