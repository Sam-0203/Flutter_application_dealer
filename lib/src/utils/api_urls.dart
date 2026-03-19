class ApiUrls {
  // static const String baseURl = 'http://192.168.0.169:5000'; //local server
  static const String baseURl = 'http://13.204.62.17'; // server
  static const String register =
      '$baseURl/send_otp'; //user registration and login
  static const String verifyOTP = '$baseURl/login'; //verify otp

  static const String languages = '$baseURl/api/languages'; //get languages
  static const String states = '$baseURl/api/states'; //get states
  static const String cities = '$baseURl/api/cities?state_id='; //get cities

  // Add a new car API's : ====>
  static const String carCompany =
      '$baseURl/api/master/car-brands'; // GET car companies
  static const String carModels =
      '$baseURl/api/master/car-models?brand_id='; // GET car models
  static const String carFuelType =
      '$baseURl/api/master/fuel-types'; // GET car fuel type
  static const String carTrasmissionTypes =
      '$baseURl/api/master/transmissions'; // GET car trasmission types
  static const String carVarietsTypes =
      '$baseURl/api/master/car-variants?model_id='; // GET car Varients
  static const String carColors =
      '$baseURl/api/master/colors?variant_id='; // GET colors
  static const String carRTOs = '$baseURl/api/master/rtos'; // GET RTOs List
  static const String carNumOfOwners =
      '$baseURl/api/master/owner-types'; // GET Car number of owners List
  static const String allCarModels =
      '$baseURl/api/master/car-models'; // GET all car models (for filter screen)

  // Car features : ====>
  static const String carSafetyFeatures =
      '$baseURl/api/features/safety'; // GET car Safety Features
  static const String carComfort =
      '$baseURl/api/features/comfort'; // GET car Comfort & Convenience
  static const String carInfotainment =
      '$baseURl/api/features/infotainment'; // GET car Infotainment features
  static const String carInterior =
      '$baseURl/api/features/interior'; // GET car carInterior Features
  static const String carExterior =
      '$baseURl/api/features/exterior'; // GET car carExterior features

  // Create a new car : ====>
  static const String postaNewCar = '$baseURl/api/cars'; // POST adding car
  static const String myPostDeatils =
      '$baseURl/api/dealer/cars'; // GET all cars based on the Token

  static const String carDetails =
      '$baseURl/api/cars/detail?car_id='; // GET car details based on car id
  static const String deleteCar =
      '$baseURl/api/cars/delete'; // DELETE car based on car id (car_id sent as form-data)

  static const String listOfCars =
      '$baseURl/api/cars'; // GET list of cars for both agent and dealer (Token based)
  static const String search =
      '$baseURl/api/cars'; // GET search results based on query params
  static const String myCarsSearch =
      '$baseURl/api/dealer/cars'; // GET my inventory search results based on query params
  static const String filter =
      '$baseURl/api/cars'; // GET filtered cars based on query params
  static const String updateCarDetails =
      '$baseURl/api/cars'; // PUT update car details based on car id (car_id sent as form-data)

  static const String carAddImagesAfterUpdate =
      '$baseURl/cars/images/add'; // POST add car images after updating a car (car_id sent as form-data)

  static const String carDeleteImagesAfterUpdate =
      '$baseURl/cars/images/delete'; // DELETE delete car images after updating a car (car_id and image_ids sent as form-data)

  // Dealer and Agent Favorite Cars : ====>
  static const String getDealerFavCar =
      '$baseURl/dealer/favorites'; // GET all favorite cars based on token

  static const String deleteFromFav =
      '$baseURl/dealer/favorites'; // DELETE a car from favorites (car_id sent as form-data)

  static const String addToFav =
      '$baseURl/dealer/favorites'; // POST add a car to favorites (car_id sent as form-data)

  static const String getAgentFavCar =
      '$baseURl/agent/favorites'; // GET all favorite cars based on token

  static const String addToFavAgent =
      '$baseURl/agent/favorites'; // POST add a car to favorites (car_id sent as form-data)

  static const String deleteFromFavAgent =
      '$baseURl/agent/favorites'; // DELETE a car from favorites (car_id sent as form-data)
}
