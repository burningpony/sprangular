Sprangular.directive 'shippingRateSelection', ->
  restrict: 'E'
  templateUrl: 'shipping/rates.html'
  scope:
    order: '='
  controller: ($scope, Cart) ->
    $scope.loading = false
    $scope.rates = []

    $scope.$watch 'order.shipping_method_id', (shippingMethodId) ->
      rate = _.find($scope.rates, (rate) -> rate.shippingMethodId == shippingMethodId)

      if rate
        $scope.order.shipTotal = rate.cost
      else
        $scope.order.shipTotal = 0

      $scope.order.updateTotals()

    # use $scope.$watchGroup when its released
    for expr in ['order.actualShippingAddress().country', 'order.actualShippingAddress().state', 'order.actualShippingAddress().zipcode']
      $scope.$watch expr, ->
        return if $scope.loading

        $scope.loading = true
        order = $scope.order
        address = order.actualShippingAddress()

        Cart.shippingRates({countryId: address.countryId, stateId: address.stateId, zipcode: address.zipcode})
            .then ((results) ->
              $scope.rates = results

              order.shipping_method_id = null unless _.find(results, (rate) -> rate.shippingMethodId == order.shipping_method_id)

              if order.shipping_method_id == null && results.length > 0
                order.shipping_method_id = results[0].shippingMethodId

              $scope.loading = false), (->

              $scope.rates = []
              $scope.loading = false)
