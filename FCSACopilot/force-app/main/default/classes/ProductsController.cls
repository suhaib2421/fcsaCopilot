public with sharing class ProductsController {
  private static Set<String> hasProduct = new Set<String>();
  private static Set<String> hadProduct = new Set<String>();

  // Create method to query from the object ProductOwned__mdt and get Id, Id__c, SalesforceName__c, Order__c, Owned__c, Owned_History__c, Product_Owned_Category__c, Product_Owned_Category__r.Category_Name__c, Product_Owned_Category__r.Category_Order__c and return as a string
  public static List<ProductOwned__mdt> getProductsOwned() {
    return [
      SELECT
        Id,
        Id__c,
        SalesforceName__c,
        Order__c,
        Owned__c,
        Owned_History__c,
        Product_Owned_Category__c,
        Product_Owned_Category__r.Category_Name__c,
        Product_Owned_Category__r.Category_Order__c
      FROM ProductOwned__mdt
      WHERE Order__c != NULL
      ORDER BY Order__c ASC NULLS LAST
    ];
  }

  // Create a method to query the object FCSA_Product__c and get CustomerProductType_ID__c, Has_Product__c, Had_Product__c and filter on Account__c field with accountIds
  public static List<FCSA_Product__c> getProductsByAccountId(
    Set<Id> accountIds
  ) {
    return [
      SELECT CustomerProductType_ID__c, Has_Product__c, Had_Product__c
      FROM FCSA_Product__c
      WHERE Account__c IN :accountIds
    ];
  }

  // Write a method called populateOwnedProductSet that takes in an accountId and uses the getProductsByAccountId method and generates two sets for hasProduct and hadProduct
  public static Set<String> populateOwnedProductSet(Id accountId) {
    for (
      FCSA_Product__c product : getProductsByAccountId(new Set<Id>{ accountId })
    ) {
      if (product.Has_Product__c) {
        hasProduct.add(product.CustomerProductType_ID__c);
      }
      if (product.Had_Product__c) {
        hadProduct.add(product.CustomerProductType_ID__c);
      }
    }

    return hasProduct;
  }

  // Write a method called assignProductOwnedHistory that takes in a list of ProductOwned__mdt and assigns the Owned_History__c field based on the hasProduct and hadProduct sets
  public static void assignProductOwnedHistory(
    List<ProductOwned__mdt> products
  ) {
    for (ProductOwned__mdt product : products) {
      if (hasProduct.contains(product.Id__c)) {
        product.Owned_History__c = 'owned';
      } else if (hadProduct.contains(product.Id__c)) {
        product.Owned_History__c = 'previous';
      }
    }
  }

  // Write a method called createProductsByCategoryMap that takes in a list of ProductOwned__mdt and returns a map of Product_Owned_Category__r.Category_Name__c to a list of ProductOwned__mdt
  public static Map<String, List<ProductOwned__mdt>> createProductsByCategoryMap(
    List<ProductOwned__mdt> products
  ) {
    Map<String, List<ProductOwned__mdt>> productsByCategory = new Map<String, List<ProductOwned__mdt>>();

    for (ProductOwned__mdt product : products) {
      if (
        !productsByCategory.containsKey(
          product.Product_Owned_Category__r.Category_Name__c
        )
      ) {
        productsByCategory.put(
          product.Product_Owned_Category__r.Category_Name__c,
          new List<ProductOwned__mdt>()
        );
      }

      productsByCategory.get(product.Product_Owned_Category__r.Category_Name__c)
        .add(product);
    }

    return productsByCategory;
  }

	// Create an inner class called ProductSortWrapper that implements Comparable to compare two ProductOwned__mdt records using the SalesforceName__c field
	public class ProductSortWrapper implements Comparable {
		public ProductOwned__mdt product;

		public ProductSortWrapper(ProductOwned__mdt product) {
			this.product = product;
		}

		public Integer compareTo(Object compareTo) {
			ProductSortWrapper compareToProduct = (ProductSortWrapper) compareTo;

			if (product.SalesforceName__c == null) {
				return -1;
			} else if (compareToProduct.product.SalesforceName__c == null) {
				return 1;
			} else {
				return product.SalesforceName__c.compareTo(
					compareToProduct.product.SalesforceName__c
				);
			}
		}
	}

	// Create a method called sortProductsByCategory that takes in a map of Product_Owned_Category__r.Category_Name__c to a list of ProductOwned__mdt and returns a map of Product_Owned_Category__r.Category_Name__c to a list of ProductSortWrapper
	public static Map<String, List<ProductSortWrapper>> sortProductsByCategory(
		Map<String, List<ProductOwned__mdt>> productsByCategory
	) {
		Map<String, List<ProductSortWrapper>> sortedProductsByCategory = new Map<String, List<ProductSortWrapper>>();

		for (String category : productsByCategory.keySet()) {
			List<ProductSortWrapper> sortedProducts = new List<ProductSortWrapper>();

			for (ProductOwned__mdt product : productsByCategory.get(category)) {
				sortedProducts.add(new ProductSortWrapper(product));
			}

			sortedProducts.sort();

			sortedProductsByCategory.put(category, sortedProducts);
		}

		return sortedProductsByCategory;
	}

	// Create a method called getProductsByCategory that takes in a map of Product_Owned_Category__r.Category_Name__c to a list of ProductSortWrapper and returns a list of ProductSortWrapper
	public static List<ProductSortWrapper> getProductsByCategory(
		Map<String, List<ProductSortWrapper>> sortedProductsByCategory
	) {
		List<ProductSortWrapper> products = new List<ProductSortWrapper>();

		for (String category : sortedProductsByCategory.keySet()) {
			products.addAll(sortedProductsByCategory.get(category));
		}

		return products;
	}

	// Create a method called getProducts that takes in an accountId and returns a list of ProductSortWrapper
	public static List<ProductSortWrapper> getProducts(Id accountId) {
		List<ProductOwned__mdt>
	}


}
