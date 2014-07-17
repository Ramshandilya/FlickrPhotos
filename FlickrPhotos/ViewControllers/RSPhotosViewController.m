//
//  RSPhotosViewController.m
//  FlickrPhotos
//
//  Created by Ramsundar Shandilya on 17/07/14.
//  Copyright (c) 2014 Ramsundar Shandilya. All rights reserved.
//

#import "RSPhotosViewController.h"
#import "RSPhotosViewModel.h"
#import "RSPhotoCollectionViewCell.h"

static NSString * const PhotoCellIdentifier = @"PhotoCellIdentifier";

@interface RSPhotosViewController ()

@property (nonatomic, strong) RSPhotosViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;
@end

@implementation RSPhotosViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupObservers];
    
    [self.photosCollectionView registerNib:[UINib nibWithNibName:@"RSPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:PhotoCellIdentifier];
    
    self.viewModel = [[RSPhotosViewModel alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods

- (void)setupObservers
{
    [self.viewModel addObserver:self forKeyPath:@"photosArray" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - UICollectionViewDataSource methods

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.viewModel.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    RSPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:PhotoCellIdentifier forIndexPath:indexPath];
    
    NSDictionary *photoInfo = [self.viewModel.photosArray objectAtIndex:indexPath.row];
    NSString *urlString = photoInfo[@"url_q"];
    
    
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig
                                  delegate:nil
                             delegateQueue:nil];
    
    NSURLSessionDownloadTask *getImageTask = [session downloadTaskWithURL:[NSURL URLWithString:urlString]
     
               completionHandler:^(NSURL *location,
                                   NSURLResponse *response,
                                   NSError *error) {
                   
                   UIImage *downloadedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                   
                   dispatch_async(dispatch_get_main_queue(), ^{
                       cell.photoImageView.image = downloadedImage;
                   });
               }];
    [getImageTask resume];
    
    return cell;
}

#pragma mark - KVO observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"photosArray"]) {
        [self.photosCollectionView reloadData];
    }
}

#pragma mark - IBActions

- (IBAction)reloadImages:(id)sender
{
    [self.viewModel updatePhotos];
}


@end
