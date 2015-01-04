//
//  DocumentPickerViewController.m
//  DocProvider
//
//  Created by Pavan Itagi on 25/12/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "DocumentPickerViewController.h"
#import "Keychain.h"

@interface DocumentPickerViewController () 

@end

@implementation DocumentPickerViewController

- (IBAction)openDocument:(id)sender {
    NSURL* documentURL = [self.documentStorageURL URLByAppendingPathComponent:@"Untitled.txt"];
    
    // TODO: if you do not have a corresponding file provider, you must ensure that the URL returned here is backed by a file
    [self dismissGrantingAccessToURL:documentURL];
}

-(void)prepareForPresentationInMode:(UIDocumentPickerMode)mode {
    // TODO: present a view controller appropriate for picker mode here
    
//    NSString *iadsf = [DocumentPickerViewController bundleSeedID];
//    [Keychain saveString:@"hello" forKey:@"check"];
    
    NSString *iadsf = [Keychain getStringForKey:@"check"];
    
    [Keychain saveString:@"hi" forKey:@"check"];
}
@end
