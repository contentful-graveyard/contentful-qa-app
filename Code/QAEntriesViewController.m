//
//  QAEntriesViewController.m
//  Q&A
//
//  Created by Boris Bügling on 19/03/14.
//  Copyright (c) 2014 Boris Bügling. All rights reserved.
//

#import <ContentfulDeliveryAPI/ContentfulDeliveryAPI.h>

#import "QAEntriesViewController.h"
#import "QAInlineFieldsViewController.h"

@interface QAEntriesViewController () <CDAEntriesViewControllerDelegate>

@property (nonatomic) CDAClient* apiClient;

@end

#pragma mark -

@implementation QAEntriesViewController

-(CDAClient *)client {
    return self.apiClient;
}

-(id)init {
    self = [super initWithCellMapping:nil];
    if (self) {
        self.apiClient = [[CDAClient alloc] initWithSpaceKey:@"id73wx4ydrgy" accessToken:@"89d01e01d7f92390a7196d60f1780293051bf0cf70f172b2fe73c4096af6f7a4"];
    }
    return self;
}

#pragma mark - CDAEntriesViewControllerDelegate

-(void)entriesViewController:(CDAEntriesViewController *)entriesViewController
       didSelectRowWithEntry:(CDAEntry *)entry {
    QAInlineFieldsViewController* inlineFieldsVC = [[QAInlineFieldsViewController alloc]
                                                    initWithEntry:entry];
    [self.navigationController pushViewController:inlineFieldsVC animated:YES];
}

#pragma mark - UITableViewDataSource

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CDAEntry* entry = self.items[indexPath.row];
    
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    cell.textLabel.text = entry.fields[entry.contentType.displayField];
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [NSString stringWithFormat:NSLocalizedString(@"Found %d results", nil), self.items.count];
}

@end
