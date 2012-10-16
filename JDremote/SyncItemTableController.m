//
//  SyncItemTableController.m
//  Cheddar
//
//  Created by Ingo Kasprzak on 16.11.09.
//  Copyright 2009 Silutions. All rights reserved.
//

#import "SyncItemTableController.h"
#import "SyncItem.h"


@implementation SyncItemTableController
@synthesize syncItemTable, syncItems;

#pragma mark -
#pragma mark Actions

- (IBAction)pushAddSyncItem:(NSButton *)sender {
	// Hinzufügen eines neuen SyncItems
	
	[self.syncItems addObject:[SyncItem syncItemWithTitle:@"Untitled"]];
		// Neues Objekt zum Array hinzufügen
	[syncItemTable noteNumberOfRowsChanged];
		// Den TableView informieren, dass sich was geändert hat => Anzeige wird aktualisiert
 	NSInteger newRowIndex = [self.syncItems count]-1;
		// Index des gerade hinzugefügten Objekts
	[syncItemTable selectRowIndexes:[NSIndexSet indexSetWithIndex:newRowIndex]
			   byExtendingSelection:NO];
		// Zeile im TableView selektieren
	[syncItemTable editColumn:[syncItemTable columnWithIdentifier:@"title"]
						  row:newRowIndex withEvent:nil select:YES];
		// Zelle mit Titel editierbar machen, Text komplett auswählen (select:YES)
}

- (IBAction)pushRemoveSyncItem:(NSButton *)sender {
	// Entfernen aller selektierten TableView-Zeilen
	NSIndexSet* indexes = [syncItemTable selectedRowIndexes];
		// Indizes der selektierten TableView-Zeilen abfragen und als NSIndexSet speichern
	[syncItems removeObjectsAtIndexes:indexes];
		// im Array die entsprechenden Objekte löschen
	[syncItemTable noteNumberOfRowsChanged];
		// Den TableView informieren, dass sich was geändert hat
}

#pragma mark -
#pragma mark Table view delegates
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView {
	// Rückgabe der Zahl der Zeilen im Array
	return [self.syncItems count];
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn
			row:(NSInteger)rowIndex {
	// Delegate: Stellt dem TableView die gewünschte Zelle zu Verfügung
	// Je TableView-Zelle wird dieses Delegate einmal aufgerufen, wenn 
	// Darstellung der entsprechenden Zellen erforderlich wird.
	SyncItem* item = [self.syncItems objectAtIndex:rowIndex];
		// aus Array das Objekt über den Index abfragen
	return [item valueForKey:[aTableColumn identifier]];
		// aus Objekt den Wert für die Spalte zurückgeben
}

- (void)tableView:(NSTableView *)aTableView
   setObjectValue:(id)anObject
   forTableColumn:(NSTableColumn *)aTableColumn
			  row:(NSInteger)rowIndex {
	// Delegate: Wird aufgerufen, wenn der Benutzer eine Zelle geändert hat
	SyncItem* item = [self.syncItems objectAtIndex:rowIndex];
		// aus dem Array das Objekt per Index abfragen
	[item setValue:anObject forKey:[aTableColumn identifier]];
		// den neuen Wert dem Objekt zuweisen
}

#pragma mark -
#pragma mark Initialization
- (id) init {
	self = [super init];
	if (self != nil) {
		self.syncItems = [NSMutableArray array];
	}
	return self;
}

- (void) dealloc {
	self.syncItemTable = NULL;
	self.syncItems = NULL;
	//[super dealloc];
}

@end
