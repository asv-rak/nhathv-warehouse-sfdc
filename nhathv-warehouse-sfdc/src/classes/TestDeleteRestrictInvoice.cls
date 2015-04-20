/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class TestDeleteRestrictInvoice {

    // Invoice generator, with or without a Line Item
	static Invoice__c createNewInvoice(Boolean withLineItem) {
	
		// Create test Merchandise
		Merchandise__c merchandise = new Merchandise__c(
				Name = 'Test Laptop',
				Quantity__c = 1000,
				Price__c = 500
			);
		insert merchandise;
	
		// Create test Invoice
		Invoice__c invoice = new Invoice__c();
		insert invoice;

		// Create test Line Item and insert it into the database, if withLineItem == true
		if (withLineItem) {
			Line_Item__c item = new Line_Item__c(
				name = '1',
				Quantity__c = 1,
				Merchandise__c = merchandise.Id,
				Invoice__c = invoice.Id
			);

			insert item;
		}
		return invoice;
	}
	
	// Single row Invoice with no Line Items => delete
    static testMethod void verifyInvoiceNoLineItemsDelete(){    
        // Create test Invoice and insert it
        Invoice__c invoice = createNewInvoice(false);
 
        // Delete the Invoice, capture the result
        Database.DeleteResult result = Database.delete(invoice, false);
 
        // Assert success, because target Invoice doesn't have Line Items
        System.assert(result.isSuccess());   
    }
	
	// Single row Invoice with Line Items => delete restrict
    static testMethod void verifyInvoiceLineItemsRestrict(){    
        // Create test Invoice and Line Item and insert them
        Invoice__c invoice = createNewInvoice(true);
 
        // Delete the Invoice, capture the result
        Database.DeleteResult result = Database.delete(invoice, false);
 
        // Assert failure-not success, because target Invoice has tracks
        System.assert(!result.isSuccess());
    }
 
    // Bulk delete of Invoice, one without Line Items, another with
    static testMethod void verifyBulkInvoiceDeleteRestrict(){    
        // Create two test Invoices, one with and without a Line Item
        Invoice__c[] invoices = new List<Invoice__c>();
        invoices.add(createNewInvoice(false));
        invoices.add(createNewInvoice(true));
 
        // Delete the Invoices, opt_allOrNone = false, capture the results.
        Database.DeleteResult[] results = Database.delete(invoices, false);
 
        // Assert success for first Invoice       
        System.assert(results[0].isSuccess());   
        // Assert not success for second Invoice
        System.assert(!results[1].isSuccess());
    }
}