class Constants {
  //base url
  ///URLS
  static const baseUrl = "https://sps-api-test.aii.et/api/v1/";
  // static const String fileUploader =
  //     'http://5.75.142.45:3002/direct-single-file-upload';

static const String fileViewer = 'http://5.75.142.45:9000/';
  //language
  static const String selectedLanguage = "SELECTED_LANGUAGE";
  static const String lanAm = "am";
  static const String lanEn = "en";
  static const String lanor = "or";
  static const String lanti = "ti";
  static const String lanso = "so";
  static const String userId = 'userId';
  static const String userAccessTokenKey = 'access_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String verifyEmail = 'verifyEmail';

  static const accessToken = "ACCESS_TOKEN";
  static const refreshToken = "REFRESH_TOKEN";
  static const userData = "USER_DATA";

  // Authentication endpoints
  static const signupUrl = "/auth/signup";
  static const signupuUrl = "/users/register"; // Keep for backward compatibility
  static const loginUrl = "/auth/login";
  static const requestOtpUrl = "/auth/request-otp";
  static const verifyOtpUrl = "/auth/verify-otp";
  static const anonymousLoginUrl = "/auth/anonymous-login";

  //products
  static const getParentProducts = "/product-categories/parent";

  //categories
  static const getParentCategories = "/product-categories/parent";
  static const getChildCategories = "/product-categories/{parentId}/children";

  //banners
  static const getAdvertisementBanners = "/advertisement-banners";

  //products
  static const getFeaturedProducts = "/products/featured";
  static const getProductById = "/products/{id}";
  static const getMostSoldProducts = "/products/public/most-sold";
  static const getBestDeals = "/products/public/best-deals";
  static const getProductsByCategory = "/products/by-category/{categoryId}";
  static const searchProducts = "/products/search";
  static const searchSuggestions = "/products/search/suggestions";

  // filter base data
  static const getBrands = "/brands";
  static const getProductTypes = "/product-types";
  static const getProductConditions = "/product-conditions";
  static const getTags = "/tags";

  // Product detail page endpoints
  static const getProductReviews = "/products/{id}/reviews";
  static const getProductRatings = "/products/{id}/ratings";
  static const getRelatedProducts = "/products/{id}/related";
  static const getProductRecommendations = "/products/{id}/recommendations";
  static const getProductRatingDistribution =
      "/products/{id}/rating-distribution";

  // Additional product detail endpoints
  static const getProductQuestions = "/products/{id}/questions";
  static const getProductSpecifications = "/products/{id}/specifications";
  static const getSimilarProducts = "/products/{id}/similar";
  static const getProductAvailability = "/products/{id}/availability";
  static const getProductShipping = "/products/{id}/shipping";

  // Cart endpoints
  static const addToCart = "/cart/add";
  static const getActiveCart = "/cart/active";
  static const updateCartItem = "/cart/items/{itemId}";
  static const removeCartItem = "/cart/items/{itemId}";
  static const clearCart = "/cart/clear";

  // Checkout endpoints
  static const getShippingAddresses = "/shipping-addresses";
  static const createShippingAddress = "/shipping-addresses";
  static const setDefaultShippingAddress =
      "/shipping-addresses/{addressId}/set-default";
  static const getShippingMethods = "/shipping-methods";
  static const getCartSummary = "/cart/summary";

  // Payment methods endpoints
  static const getPaymentMethods = "/payment-methods";
  static const getPaymentMethodById = "/payment-methods/{id}";

  // Orders endpoints
  static const createOrder = "/orders";
  static const getOrders = "/orders";
  static const getOrderById = "/orders/{id}";
  static const getMyOrders = "/orders/my-orders";
  static const getOrderSummary = "/orders/summary";

  // Wishlist endpoints
  static const getWishlist = "/wishlist";
  static const addToWishlist = "/wishlist";
  static const removeFromWishlist = "/wishlist/{productId}";
  static const checkWishlistItem = "/wishlist/check/{productId}";

  // Location endpoints
  static const getRegions = "/regions";
  static const getDistrictsByRegion = "/districts/by-region/{regionId}";
  static const getWoredasByZone = "/woredas/by-zone/{zoneId}";

  // Notification endpoints
  static const getUnreadNotifications = "/notification/unread-messages";
  static const getNotificationById = "/notification/{id}";
  static const markNotificationAsRead = "/notification/{id}/mark-as-read";

  // LiveKit video call endpoints (legacy - may be removed)
  static const liveKitGetToken = "/livekit/token";
  static const liveKitCreateRoom = "/livekit/room";
  static const liveKitEndRoom = "/livekit/room/{roomName}";
  static const liveKitGetRoomInfo = "/livekit/room/{roomName}";

  // Direct Call endpoints
  static const directCallRequest = "/direct-call/request";
  static const directCallAccept = "/direct-call/accept/{sessionId}";
  static const directCallReject = "/direct-call/reject/{sessionId}";
  static const directCallEnd = "/direct-call/end/{sessionId}";
  static const directCallPending = "/direct-call/pending";

  // Report endpoints
  static const reportDraft = "/reports/draft/{callSessionId}";
}
