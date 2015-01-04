//
//  ViewController.m
//  MyDocProvider
//
//  Created by Pavan Itagi on 25/12/14.
//  Copyright (c) 2014 Pavan Itagi. All rights reserved.
//

#import "ViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "Keychain.h"

@interface ViewController () <UIDocumentPickerDelegate,UIDocumentMenuDelegate>
- (IBAction)showDocumentPicker:(id)sender;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showDocumentPicker:(id)sender
{
//    [Keychain saveString:@"hello" forKey:@"check"];
    
    NSString *iadsf = [Keychain getStringForKey:@"check"];
    
    return;
    UIDocumentMenuViewController *documentPickerVC = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:@[(NSString *)kUTTypeRTF,(NSString *)kUTTypePNG,(NSString *)kUTTypeText,(NSString *)kUTTypePlainText,(NSString *)kUTTypePDF, (NSString *)kUTTypeImage] inMode:UIDocumentPickerModeImport];
    documentPickerVC.delegate = self;
    [documentPickerVC addOptionWithTitle:@"Custom Option" image:nil order:UIDocumentMenuOrderFirst handler:^{
        NSLog(@"UIDocumentMenuViewController completion handler");
    }];
    
    documentPickerVC.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:documentPickerVC animated:YES completion:^{}];
    UIPopoverPresentationController *presentationPopover = [documentPickerVC popoverPresentationController];
    documentPickerVC.popoverPresentationController.sourceView = [self view];
    presentationPopover.permittedArrowDirections = UIPopoverArrowDirectionDown;
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker
{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:^{}];
}

- (void)documentMenuWasDismissed:(UIDocumentMenuViewController *)documentMenu
{
    NSLog(@"UIDocumentMenuViewController dismissed");
}

#pragma mark - UIDocumentPickerDelegate methods
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url
{
    NSLog(@"documentPicker: didPickDocumentAtURL: %@", url);
    if(url == nil) {
        NSLog(@"documentPicker: no url available.");
    } else{
        BOOL startAccessingWorked = [url startAccessingSecurityScopedResource];
        NSURL *ubiquityURL = [[NSFileManager defaultManager] URLForUbiquityContainerIdentifier:nil];
        NSLog(@"UIDocumentPickerViewController: ubiquityURL: %@",ubiquityURL);
        NSLog(@"UIDocumentPickerViewController: startAccessingWorked: %d",startAccessingWorked);        
        NSFileCoordinator *fileCoordinator = [[NSFileCoordinator alloc] init];
        NSError *error = nil;
        [fileCoordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
            NSLog(@"NSFileCoordinator: error: %@",error);
            NSData *data = [NSData dataWithContentsOfURL:newURL];
            // Do what ever you want with the Data
        }];
        [url stopAccessingSecurityScopedResource];
    }
}

- (void)documentPickerWasCancelled:(UIDocumentPickerViewController *)controller
{
    NSLog(@"UIDocumentPickerViewController cancelled");
}

@end
