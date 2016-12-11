//
//  HMAirBaseWindowController.m
//  KCD
//
//  Created by Hori,Masaki on 2016/12/04.
//  Copyright © 2016年 Hori,Masaki. All rights reserved.
//

#import "HMAirBaseWindowController.h"

#import "HMServerDataStore.h"
#import "HMKCAirBase.h"

#import "HMAreaNameTransformer.h"

@interface HMAirBaseWindowController ()

@property (nonatomic, weak) IBOutlet NSMatrix *areaMatrix;
@property (nonatomic, weak) IBOutlet NSSegmentedControl *squadronTab;
@property (nonatomic, strong) IBOutlet NSArrayController *airBaseController;
@property (nonatomic, strong) IBOutlet NSTableView *planesTable;

@property (nonatomic, strong) NSNumber *areaId;
@property (nonatomic, strong) NSNumber *rId;

@end

@implementation HMAirBaseWindowController
@synthesize areaId = _areaId;
@synthesize rId = _rId;

- (id)init
{
    self = [super initWithWindowNibName:NSStringFromClass([self class])];
    return self;
}

- (NSManagedObjectContext *)managedObjectContext
{
    return [HMServerDataStore defaultManager].managedObjectContext;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    self.rId = @(1);
    
    [self.airBaseController addObserver:self
                             forKeyPath:@"content"
                                options:0
                                context:NULL];
    [self updatePredicate];
    [self updateAreaRadio];
    [self updatePlaneSegment];
}

- (void)updateAreaRadio
{
    NSArray *content = self.airBaseController.content;
    NSCountedSet *areaSet = [NSCountedSet set];
    for(HMKCAirBase *airBase in content) {
        [areaSet addObject:airBase.area_id];
    }
    
    NSArray<NSNumber *> *areas = [areaSet.allObjects sortedArrayUsingSelector:@selector(compare:)];
    NSInteger cellCount = self.areaMatrix.numberOfRows * self.areaMatrix.numberOfColumns;
    if(areas.count != cellCount) {
        NSInteger diff = areas.count - self.areaMatrix.numberOfColumns;
        while(areas.count != self.areaMatrix.numberOfColumns) {
            if(diff < 0) {
                [self.areaMatrix removeColumn:0];
            } else {
                [self.areaMatrix addColumn];
            }
        }
    }
    
    if(self.areaMatrix.numberOfColumns == 0) {
        [self.areaMatrix addColumn];
        NSCell *areaCell = [self.areaMatrix cellAtRow:0 column:0];
        areaCell.title = @"";
        areaCell.tag = -10000;
        
        self.areaMatrix.enabled = NO;
    } else {
        self.areaMatrix.enabled = YES;
    }
    
    [areas enumerateObjectsUsingBlock:^(NSNumber * _Nonnull area, NSUInteger idx, BOOL * _Nonnull stop) {
        NSValueTransformer *t = [NSValueTransformer valueTransformerForName:@"HMAreaNameTransformer"];
        NSCell *areaCell = [self.areaMatrix cellAtRow:0 column:idx];
        areaCell.title = [t transformedValue:area];
        areaCell.tag = area.integerValue;
    }];
    //    [self.areaMatrix sizeToFit];
    self.areaId = areas.firstObject;
}
- (void)updatePlaneSegment
{
    NSArray *content = self.airBaseController.content;
    NSCountedSet *areaSet = [NSCountedSet set];
    for(HMKCAirBase *airBase in content) {
        [areaSet addObject:airBase.area_id];
    }
    
    NSInteger count = [areaSet countForObject:self.areaId];
    for(NSInteger i = 0; i < 3; i++) {
        if(i < count) {
            [self.squadronTab setEnabled:YES forSegment:i];
        } else {
            [self.squadronTab setEnabled:NO forSegment:i];
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if([keyPath isEqualToString:@"content"]) {
        [self updateAreaRadio];
        [self updatePlaneSegment];
        return;
    }
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)updatePredicate
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"area_id = %@ AND rid = %@", self.areaId, self.rId];
    self.airBaseController.filterPredicate = predicate;
    [self.airBaseController setSelectionIndex:0];
    [self.planesTable deselectAll:nil];
}

- (void)setAreaId:(NSNumber *)areaId
{
    _areaId = areaId;
    [self updatePredicate];
    [self updatePlaneSegment];
}
- (void)setRId:(NSNumber *)rId
{
    _rId = rId;
    [self updatePredicate];
    [self updatePlaneSegment];
}

#pragma mark - NSTableViewDelegate & NSTableViewDataSource

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSView *itemView = [tableView makeViewWithIdentifier:tableColumn.identifier owner:nil];
    return itemView;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row
{
    return NO;
}
@end
