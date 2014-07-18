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
#import "FBKVOController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "HTProgressHUD.h"

static NSString * const PhotoCellIdentifier = @"PhotoCellIdentifier";

@interface RSPhotosViewController ()

@property (nonatomic, strong) RSPhotosViewModel *viewModel;

@property (weak, nonatomic) IBOutlet UICollectionView *photosCollectionView;

@end

@implementation RSPhotosViewController
{
    FBKVOController *_KVOController;
    HTProgressHUD *spinner;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _KVOController = [FBKVOController controllerWithObserver:self];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.viewModel = [[RSPhotosViewModel alloc] init];
    [self setupObservers];
    
    spinner = [[HTProgressHUD alloc] init];
    
    [self reloadData];
    
    [self.photosCollectionView registerNib:[UINib nibWithNibName:@"RSPhotoCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:PhotoCellIdentifier];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Custom Methods

- (void)setupObservers
{
    [_KVOController observe:self.viewModel keyPath:@"photosArray" options:NSKeyValueObservingOptionNew block:^(id observer, id object, NSDictionary *change) {
        [spinner hideWithAnimation:YES];
        [self.photosCollectionView reloadData];
    }];
    
}

- (void)reloadData
{
    spinner.text = @"Loading..";
    [spinner showInView:self.view];
    
    [self.viewModel updatePhotos];
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
    
    [cell.photoImageView setImageWithURL:[NSURL URLWithString:urlString]];
    
    return cell;
}

#pragma mark - IBActions

- (IBAction)reloadImages:(id)sender
{
    [self reloadData];
}

- (void)dealloc
{
    [_KVOController unobserveAll];
}

@end
