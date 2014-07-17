//
//  RSPhotosViewModel.m
//  FlickrPhotos
//
//  Created by Ramsundar Shandilya on 17/07/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "RSPhotosViewModel.h"

@implementation RSPhotosViewModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _photosArray = [[NSMutableArray alloc] init];
        [self updatePhotos];
    }
    return self;
}

- (void)updatePhotos
{
    [self fetchImagesCompletionBlock:^(NSArray *photos) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.photosArray removeAllObjects];
            [[self mutableArrayValueForKeyPath:@"photosArray"] addObjectsFromArray:photos];
//            [self didChangeValueForKey:@"photosArray"];
            [self setPhotoId:@"hdbfhdb"];
        });
        
    } failureBlock:^(NSError *error) {
        NSLog(@"ERROR : %@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FlickrApp"
                                                            message:@"Error fetching feed."
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
        });
    }];
}

- (void)fetchImagesCompletionBlock:(void (^)(NSArray *photos))success
                      failureBlock:(void (^)(NSError *error))failure
{
    NSString *urlString = @"https://api.flickr.com/services/rest/?method=flickr.interestingness.getList&api_key=80bfbd87ab15ec86dca6854950d6d1db&per_page=99&format=json&nojsoncallback=1&extras=url_q,url_z";
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration delegate:nil delegateQueue:nil];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];

    [request setHTTPMethod:@"GET"];
    
    NSURLSessionDataTask *getDataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*) response;
        
        if (!error && httpResponse.statusCode == 200) {
            
            NSError* parseError;
            id json = [NSJSONSerialization
                       JSONObjectWithData:data
                       options:NSJSONReadingAllowFragments
                       error:&parseError];
            
            if (parseError) {
                failure(parseError);
            } else {
                
                if (json) {
                    if ([json isKindOfClass:[NSDictionary class]]) {
                        
                        NSDictionary *resultDictionary = (NSDictionary *) json;
                        NSDictionary *dict = [resultDictionary objectForKey:@"photos"];
                        NSArray *results = [dict objectForKey:@"photo"];
                        success(results);
                        
                    } else {
                        
                        NSDictionary *userInfo = @{
                                                   NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to fetch photos", nil),
                                                   };
                        error = [NSError errorWithDomain:@"" code:-100 userInfo:userInfo];
                        failure(error);
                    }
                }
            }
            
        } else {
            NSDictionary *userInfo = @{
                                       NSLocalizedDescriptionKey: NSLocalizedString(@"Failed to fetch photos", nil),
                                       };
            error = [NSError errorWithDomain:@"" code:-100 userInfo:userInfo];
            failure(error);
        }
    }];
    
    [getDataTask resume];
}
@end
