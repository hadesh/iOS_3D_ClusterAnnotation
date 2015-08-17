//
//  QuadTree.h
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct QuadTreeNodeData
{
    double x;
    double y;
    void * data;
} QuadTreeNodeData;
QuadTreeNodeData QuadTreeNodeDataMake(double x, double y, void* data);

typedef struct BoundingBox
{
    double x0; double y0;
    double xm; double ym;
} BoundingBox;
BoundingBox BoundingBoxMake(double x0, double y0, double xm, double ym);

typedef struct QuadTreeNode
{
    struct QuadTreeNode * northEast;
    struct QuadTreeNode * northWest;
    struct QuadTreeNode * southEast;
    struct QuadTreeNode * southWest;
    
    BoundingBox boundingBox;
    int bucketCapacity;
    QuadTreeNodeData * points;
    int pointsCount;
} QuadTreeNode;
QuadTreeNode* QuadTreeNodeMake(BoundingBox boundingBox, int bucketCapacity);

/*!
 建立四叉树
 @param data        用于建树的节点数据指针
 @param count       节点数据的个数
 @param boundingBox 四叉树覆盖的范围
 @param capacity    单节点能容纳的节点数据个数
 @return 四叉树的根节点
 */
QuadTreeNode* QuadTreeBuildWithData(QuadTreeNodeData *data, NSUInteger count, BoundingBox boundingBox, int capacity);

/*!
 在四叉树中插入节点数据
 @param node 插入的节点位置
 @param data 需要插入的节点数据
 @return 成功插入返回true，否则false
 */
bool QuadTreeNodeInsertData(QuadTreeNode* node, QuadTreeNodeData data);

/*!
 拆分节点
 @param node 输入需拆分的节点
 */
void QuadTreeNodeSubdivide(QuadTreeNode* node);

/*!
 判断节点数据是否在box范围内
 @param box  box范围
 @param data 节点数据
 @return 若data在box内，返回true，否则false
 */
bool BoundingBoxContainsData(BoundingBox box, QuadTreeNodeData data);

/*!
 判断两box是否相交
 */
bool BoundingBoxIntersectsBoundingBox(BoundingBox b1, BoundingBox b2);

typedef void(^DataReturnBlock)(QuadTreeNodeData data);
void QuadTreeGatherDataInRange(QuadTreeNode* node, BoundingBox range, DataReturnBlock block);

/*!
 清空四叉树
 @param node 四叉数根节点
 */
void FreeQuadTreeNode(QuadTreeNode* node);

