import 'package:flutter/material.dart';

mixin PaginationMixin<T extends StatefulWidget> on State<T> {
  static const int defaultPageSize = 10;
  int currentPage = 1;
  bool isLoadingMore = false;
  late ScrollController scrollController;

  int get pageSize => defaultPageSize;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    scrollController.addListener(scrollListener);
  }

  @override
  void dispose() {
    scrollController.removeListener(scrollListener);
    scrollController.dispose();
    super.dispose();
  }

  void scrollListener() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent - 200) {
      loadMoreItems();
    }
  }

  void loadMoreItems();

  void resetPagination() {
    setState(() {
      currentPage = 1;
      isLoadingMore = false;
    });
  }

  int getDisplayItemCount(int totalItems) {
    final itemCount = currentPage * pageSize;
    return itemCount > totalItems ? totalItems : itemCount;
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  bool get canLoadMore => true;
}
