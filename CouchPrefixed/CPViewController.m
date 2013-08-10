//
//  CPViewController.m
//  CouchPrefixed
//
//  Created by Daniel Ericsson on 2013-08-02.
//  Copyright (c) 2013 MONOWERKS. All rights reserved.
//

#import "CPViewController.h"
// -- Utils
#import <CouchCocoa/CouchCocoa.h>
#import <TouchDB/TouchDB.h>

@interface CPViewController ()

@property (nonatomic,  readonly, strong) CouchServer *couchServer;
@property (nonatomic,  readonly, strong) CouchDatabase *database;
@property (nonatomic,  readonly, strong) CouchDesignDocument *designDoc;
@property (nonatomic, readwrite, strong) CouchLiveQuery *liveQuery;
@property (nonatomic, readwrite, strong) CouchQuery *query;

@end

@implementation CPViewController

@synthesize couchServer = _couchServer;
@synthesize database = _database;
@synthesize designDoc = _designDoc;

#undef COUCHDB
#define TOUCHDB

- (void)viewDidLoad {
	[super viewDidLoad];
    
    //gRESTLogLevel = kRESTLogRequestURLs;
    
    // Create test document
#if (defined TOUCHDB || defined COUCHDB)
    CouchDocument *doc = [self.database documentWithID:@"doc_:/?#[]@!$&'()*+,;="];
    NSDictionary *props = @
    {
        @"type": @"docwithcrazyid",
    };
    
    // Put it into db
    NSError *error;
    RESTOperation *restOp = [doc putProperties:props];
    if (![restOp wait:&error]) {
        NSLog(@"%@", [error userInfo]);
    };
#endif
    
    // Try live-querying it
#if (defined TOUCHDB)
    self.liveQuery = [[self.database getAllDocuments] asLiveQuery];
    self.liveQuery.startKey = @"doc_:/?#[]@!$&'()*+,;=";
    self.liveQuery.prefetch = YES;
    [self.liveQuery addObserver:self forKeyPath:@"rows" options:NSKeyValueObservingOptionNew context:NULL];
    [self.liveQuery wait];
#endif
    
    // Try normal query
#if (defined TOUCHDB || defined COUCHDB)
    self.query = [self.database getAllDocuments];
    self.liveQuery.startKey = @"doc_:/?#[]@!$&'()*+,;=";
    self.query.prefetch = YES;
    [self.query addObserver:self forKeyPath:@"rows" options:NSKeyValueObservingOptionNew context:NULL];
    [[self.query start] wait];
#endif
    
    // Try a view query
#if (defined TOUCHDB)
    CouchQuery *viewQuery = [self.designDoc queryViewNamed:@"view:/?#[]@!$&'()*+,;="];
    for (CouchQueryRow *row in [viewQuery rows]) {
        NSLog(@"row from view query: %@", row);
    }
#endif
    
    // Try to get document by id
#if (defined TOUCHDB || defined COUCHDB)
    CouchDocument *document = [self.database documentWithID:@"doc_:/?#[]@!$&'()*+,;="];
    NSLog(@"doc fetched by Id: %@", document.properties);
#endif
    
    // Try replicating DB
#if (defined TOUCHDB)
    NSURL *URL = [NSURL URLWithString:@"http://localhost:5984/replicationdb_$()+-/"];
    [self.database replicateWithURL:URL exclusively:YES];
#endif
}


#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isKindOfClass:[CouchLiveQuery class]]) {
        for (id row in [object rows]) {
            NSLog(@"row from live query: %@", row);
        }
    }
    
    if ([object isKindOfClass:[CouchQuery class]]) {
        for (id row in [object rows]) {
            NSLog(@"row from query: %@", row);
        }
    }
}


#pragma mark - Private properties

- (CouchDesignDocument *)designDoc {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _designDoc = [self.database designDocumentWithName:@"designdoc_$()+-/"];
        [_designDoc defineViewNamed:@"view:/?#[]@!$&'()*+,;=" mapBlock:^(NSDictionary *doc, TDMapEmitBlock emit) {
            if ([doc[@"type"] isEqualToString:@"docwithcrazyid"]) {
                emit(doc[@"_id"], doc);
            }
        } version:@"1.1"];

    });
    
    return _designDoc;
}

- (CouchServer *)couchServer {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
#ifdef TOUCHDB
        NSString *serverPath = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask][0] path];
        _couchServer = [[CouchTouchDBServer alloc] initWithServerPath:serverPath];
#else
        _couchServer = [[CouchServer alloc] init];
#endif
    });
    
    return _couchServer;
}

- (CouchDatabase *)database {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        _database = [self.couchServer databaseNamed:@"db_$()+-/"];
        if (![_database ensureCreated:&error]) {
            NSLog(@"%@", [error userInfo]);
        }
        
        _database.tracksChanges = YES;
    });
    
    return _database;
}

@end
