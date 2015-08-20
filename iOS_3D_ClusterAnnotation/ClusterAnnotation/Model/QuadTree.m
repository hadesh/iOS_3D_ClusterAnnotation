//
//  QuadTree.m
//  officialDemo2D
//
//  Created by yi chen on 14-5-15.
//  Copyright (c) 2014年 AutoNavi. All rights reserved.
//

#import "QuadTree.h"

#pragma mark - Constructors

QuadTreeNodeData QuadTreeNodeDataMake(double x, double y, void* data)
{
    QuadTreeNodeData d; d.x = x; d.y = y; d.data = data;
    return d;
}

BoundingBox BoundingBoxMake(double x0, double y0, double xm, double ym)
{
    BoundingBox bb; bb.x0 = x0; bb.y0 = y0; bb.xm = xm; bb.ym = ym;
    return bb;
}

QuadTreeNode* QuadTreeNodeMake(BoundingBox boundary, int bucketCapacity)
{
    QuadTreeNode* node = malloc(sizeof(QuadTreeNode));
    node->northWest = NULL;
    node->northEast = NULL;
    node->southWest = NULL;
    node->southEast = NULL;
    
    node->boundingBox = boundary;
    node->bucketCapacity = bucketCapacity;
    node->pointsCount = 0;
    node->points = malloc(sizeof(QuadTreeNodeData) * bucketCapacity);
    
    return node;
}

#pragma mark - Bounding Box Functions

bool BoundingBoxContainsData(BoundingBox box, QuadTreeNodeData data)
{
    bool containsX = box.x0 <= data.x && data.x <= box.xm;
    bool containsY = box.y0 <= data.y && data.y <= box.ym;
    
    return containsX && containsY;
}

bool BoundingBoxIntersectsBoundingBox(BoundingBox b1, BoundingBox b2)
{
    return (b1.x0 <= b2.xm && b1.xm >= b2.x0 && b1.y0 <= b2.ym && b1.ym >= b2.y0);
}

#pragma mark - Quad Tree Functions

void QuadTreeNodeSubdivide(QuadTreeNode* node)
{
    BoundingBox box = node->boundingBox;
    
    double xMid = (box.xm + box.x0) / 2.0;
    double yMid = (box.ym + box.y0) / 2.0;
    
    BoundingBox northWest = BoundingBoxMake(box.x0, box.y0, xMid, yMid);
    node->northWest = QuadTreeNodeMake(northWest, node->bucketCapacity);
    
    BoundingBox northEast = BoundingBoxMake(xMid, box.y0, box.xm, yMid);
    node->northEast = QuadTreeNodeMake(northEast, node->bucketCapacity);
    
    BoundingBox southWest = BoundingBoxMake(box.x0, yMid, xMid, box.ym);
    node->southWest = QuadTreeNodeMake(southWest, node->bucketCapacity);
    
    BoundingBox southEast = BoundingBoxMake(xMid, yMid, box.xm, box.ym);
    node->southEast = QuadTreeNodeMake(southEast, node->bucketCapacity);
}

bool QuadTreeNodeInsertData(QuadTreeNode* node, QuadTreeNodeData data)
{
    if (!BoundingBoxContainsData(node->boundingBox, data))
    {
        return false;
    }
    
    if (node->pointsCount < node->bucketCapacity)
    {
        node->points[node->pointsCount++] = data;
        return true;
    }
    
    /* 若节点容量已满，且该节点为叶子节点，则向下扩展. */
    if (node->northWest == NULL)
    {
        QuadTreeNodeSubdivide(node);
    }
    
    if (QuadTreeNodeInsertData(node->northWest, data)) return true;
    if (QuadTreeNodeInsertData(node->northEast, data)) return true;
    if (QuadTreeNodeInsertData(node->southWest, data)) return true;
    if (QuadTreeNodeInsertData(node->southEast, data)) return true;
    
    return false;
}

QuadTreeNode* QuadTreeBuildWithData(QuadTreeNodeData *data, NSUInteger count, BoundingBox boundingBox, int capacity)
{
    
    QuadTreeNode* root = QuadTreeNodeMake(boundingBox, capacity);
    for (int i = 0; i < count; i++)
    {
        QuadTreeNodeInsertData(root, data[i]);
    }
    
    return root;
}

void QuadTreeGatherDataInRange(QuadTreeNode* node, BoundingBox range, DataReturnBlock block)
{
    /* 若节点的覆盖范围与range不相交，则返回. */
    if (!BoundingBoxIntersectsBoundingBox(node->boundingBox, range))
    {
        return;
    }
    
    
    for (int i = 0; i < node->pointsCount; i++)
    {
        /* 若节点数据在range内，则调用block记录. */
        if (BoundingBoxContainsData(range, node->points[i]))
        {
            block(node->points[i]);
        }
    }
    
    /* 若已是叶子节点，返回. */
    if (node->northWest == NULL)
    {
        return;
    }
    
    /* 不是叶子节点，继续向下查找. */
    QuadTreeGatherDataInRange(node->northWest, range, block);
    QuadTreeGatherDataInRange(node->northEast, range, block);
    QuadTreeGatherDataInRange(node->southWest, range, block);
    QuadTreeGatherDataInRange(node->southEast, range, block);
    
}

void FreeQuadTreeNode(QuadTreeNode* node)
{
    if (node->northWest != NULL) FreeQuadTreeNode(node->northWest);
    if (node->northEast != NULL) FreeQuadTreeNode(node->northEast);
    if (node->southWest != NULL) FreeQuadTreeNode(node->southWest);
    if (node->southEast != NULL) FreeQuadTreeNode(node->southEast);
    
    for (int i=0; i < node->pointsCount; i++)
    {
        //        free(node->points[i].data);
        CFRelease(node->points[i].data);
    }
    free(node->points);
    free(node);
}