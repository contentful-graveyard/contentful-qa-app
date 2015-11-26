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

-(void)dealloc {
    [self removeObserver:self forKeyPath:@"entries" context:NULL];
}

-(id)init {
    self = [super initWithCellMapping:@{}];
    if (self) {
        self.apiClient = [[CDAClient alloc] initWithSpaceKey:@"id73wx4ydrgy" accessToken:@"89d01e01d7f92390a7196d60f1780293051bf0cf70f172b2fe73c4096af6f7a4"];
        
        [self addObserver:self forKeyPath:@"entries" options:0 context:NULL];
    }
    return self;
}

-(void)observeValueForKeyPath:(NSString *)keyPath
                     ofObject:(id)object
                       change:(NSDictionary *)change
                      context:(void *)context {
    if (self.items.count == 0) {
        UILabel* noResultsView = [[UILabel alloc] initWithFrame:self.view.bounds];
        noResultsView.alpha = 0.0;
        noResultsView.backgroundColor = [UIColor whiteColor];
        noResultsView.font = [UIFont boldSystemFontOfSize:20.0];
        noResultsView.numberOfLines = 0;
        noResultsView.text = [NSString stringWithFormat:NSLocalizedString(@"Keine Ergebnisse für \"%@\" gefunden.", nil), self.query[@"query"]];
        noResultsView.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:noResultsView];
        
        [UIView animateWithDuration:0.2 animations:^{
            noResultsView.alpha = 1.0;
        }];
    }
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
