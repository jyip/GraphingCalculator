//
//  GraphView.h
//  GraphingCalculator
//
//  Created by terran on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (double)yValueForGraphView:(GraphView *)sender atX:(double)graphX;
@end

@interface GraphView : UIView

@property (nonatomic) CGPoint origin;
@property (nonatomic) CGFloat scale;

- (void)pinch:(UIPinchGestureRecognizer *)gesture;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
