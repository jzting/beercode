//
//  ViewController.m
//  beercode
//
//  Created by Jason Ting on 12/19/12.
//  Copyright (c) 2012 Jason Ting. All rights reserved.
//

#import "ViewController.h"
#import "ZBarSDK.h"
#import "AFJSONRequestOperation.h"

@interface ViewController () <ZBarReaderDelegate>

@end

@implementation ViewController {
    ZBarReaderViewController *_reader;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    _reader = [ZBarReaderViewController new];
    _reader.readerDelegate = self;
//    [_reader.scanner setSymbology:0
//                           config:ZBAR_CFG_ENABLE
//                               to:0];
//    [_reader.scanner setSymbology:ZBAR_UPCA
//                           config:ZBAR_CFG_ENABLE
//                               to:1];
//    [_reader.scanner setSymbology:ZBAR_UPCE
//                           config:ZBAR_CFG_ENABLE
//                               to:1];
    _reader.readerView.zoom = 1.0;
}

- (IBAction)scan:(id)sender {
    [self presentViewController:_reader animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info {
    ZBarSymbolSet *results = [info objectForKey:ZBarReaderControllerResults];
    ZBarSymbol *result;

    for(ZBarSymbol *symbol in results) {
        result = symbol;
    }

    __weak ViewController *weakSelf = self;

    [reader dismissViewControllerAnimated:YES completion:^{
        NSLog(@"code: %@", result.data);

        NSString *upc = [NSString stringWithFormat:@"http://www.ratebeer.com/json/upc.asp?upc=%lld&k=2e1ob20b6n0gc999r", [result.data longLongValue]];
        NSURL *url = [NSURL URLWithString:upc];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"response: %@", JSON);
            NSString *beerId = [[JSON valueForKeyPath:@"BeerID"] lastObject];
            NSLog(@"beerId: %@", beerId);

            if (beerId) {
                NSString *beerURL = [NSString stringWithFormat:@"http://www.ratebeer.com/json/bff.asp?bd=%@&k=2e1ob20b6n0gc999r", beerId];
                NSLog(@"beerURL: %@", beerURL);
                NSURL *url = [NSURL URLWithString:beerURL];
                NSURLRequest *request = [NSURLRequest requestWithURL:url];

                AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSString *beerName = [[JSON valueForKeyPath:@"BeerName"] lastObject];
                    double rating = [[[JSON valueForKeyPath:@"OverallPctl"] lastObject] doubleValue];

                    NSLog(@"beerName: %@", beerName);
                    NSLog(@"rating: %0.2f", round(rating));

                    if (beerName && rating) {
                        weakSelf.nameLabel.text = beerName;
                        weakSelf.ratingLabel.text = [NSString stringWithFormat:@"%0.0f", round(rating)];
                    } else {
                        weakSelf.nameLabel.text = @"Not found";
                        weakSelf.ratingLabel.text = @"";
                    }
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"error: %@", error);
                    weakSelf.nameLabel.text = @"Error";
                    weakSelf.ratingLabel.text = @"";
                }];
                [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
                [operation start];
            } else {
                weakSelf.nameLabel.text = @"Not found";
                weakSelf.ratingLabel.text = @"";
            }

        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"error: %@", error);
            weakSelf.nameLabel.text = @"Error";
            weakSelf.ratingLabel.text = @"";
        }];
        [AFJSONRequestOperation addAcceptableContentTypes:[NSSet setWithObjects:@"text/html", nil]];
        [operation start];

    }];
}

@end
