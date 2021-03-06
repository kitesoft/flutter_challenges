
import 'package:flutter/material.dart';
import 'package:ramen_restaurant/src/blocs/app_bloc.dart';
import 'package:ramen_restaurant/src/data/constants.dart';
import 'package:ramen_restaurant/src/models/food.dart';
import 'package:ramen_restaurant/src/widgets/add_to_cart_animation.dart';
import 'package:ramen_restaurant/src/widgets/bounce_in_animation.dart';
import 'package:ramen_restaurant/src/widgets/food_card.dart';

class HomeScreen extends StatefulWidget {
  @override
  HomeScreenState createState() {
    return new HomeScreenState();
  }
}

class HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final foodCardHeight = 360.0; // retrieved from food_card.dart
  double screenHeight;
  double screenWidth;

  double yStartPosition;
  double yEndPosition;

  double xStartPosition;
  double xEndPosition;

  PageController _pageViewController = PageController(
    initialPage: 0,
    keepPage: false,
    viewportFraction: 0.7,
  );

  AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addStatusListener((AnimationStatus status) {
            if (status == AnimationStatus.completed) {
              _animationController.reset();
            }
          });
  }

  final List<Food> _foods = Food.getAllFoods();

  dispose() {
    _animationController.dispose();
    _pageViewController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final bloc = AppProvider.of(context);
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    yStartPosition = screenHeight - foodCardHeight / 2;
    xStartPosition = screenWidth / 2 - 30.0;

    yEndPosition = 18.0 + 10.0;
    xEndPosition = screenWidth - 18.0 - 10.0;

    return Stack(
      children: <Widget>[
        Column(children: [
          Expanded(
            child: StreamBuilder(
              stream: bloc.currentpage,
              builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                    color: BGColors.all[0],
                  );
                }
                return Container(
                  color: BGColors.all[snapshot.data],
                );
              },
            ),
          ),
          Expanded(
            child: Container(
              color: Color(0xFFffffff),
            ),
          ),
        ]),
        _buildScaffold(context, bloc),
        AddToCartAnimation(
          begin: Offset(xStartPosition, yStartPosition),
          end: Offset(xEndPosition, yEndPosition),
          animationController: _animationController,
        ),
      ],
    );
  }

  Widget _buildScaffold(context, AppBloc bloc) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        leading: BackButton(),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        actions: <Widget>[
          Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: Icon(Icons.shopping_cart),
              ),
              Positioned(
                top: 6.0,
                right: 0.0,
                child: StreamBuilder(
                  stream: bloc.itemsInCart,
                  builder: (ctx, AsyncSnapshot<int> snapshot) {
                    if (snapshot.hasData) {
                      return BounceInAnimation(
                        replayable: true,
                        child: Container(
                          alignment: Alignment.center,
                          width: 18.0,
                          height: 18.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle, color: AppColors.yellow),
                          margin: const EdgeInsets.only(right: 10.0),
                          child: Text(bloc.total.toString().toUpperCase(),
                              style: TextStyle(
                                  color: Colors.white, fontSize: 14.0)),
                        ),
                      );
                    }
                    return Container();
                  },
                ),
              ),
            ],
          ),
        ],
        title: Text(
          'TODAY\'S SPECIAL',
          style: TextStyle(fontSize: 18.0, letterSpacing: 1.0),
        ),
      ),
      body: Stack(
        children: <Widget>[
          //main background
          StreamBuilder(
            stream: bloc.currentpage,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              return PageView.builder(
                controller: _pageViewController,
                itemCount: _foods.length,
                onPageChanged: (int pageNumber) =>
                    bloc.setCurrentPage(pageNumber),
                itemBuilder: (BuildContext context, int index) {
                  final Food currentFood = _foods[index];
                  return AnimatedBuilder(
                    animation: _pageViewController,
                    child: GestureDetector(
                      onTap: null,
                      child: FoodCard(
                        food: currentFood,
                        onAddToCart: (int quantity) async {
                          await _animationController.forward();
                          bloc.addItemsToCart(quantity);
                        },
                      ),
                    ),
                    builder: (BuildContext ctx, Widget child) {
                      double value = 1.0;

                      if (_pageViewController.position.haveDimensions) {
                        value = _pageViewController.page - index;
                        value = (1 - (value.abs() * .5)).clamp(0.0, 1.0);
                      }
                      return new Transform.scale(
                        // scale: 1.0,
                        scale: Curves.easeOut.transform(value) * 1 + 0.08,
                        child: child,
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
