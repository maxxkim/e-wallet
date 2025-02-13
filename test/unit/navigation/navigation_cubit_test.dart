// test/unit/navigation/navigation_cubit_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:zippy/presentation/bloc/navigation/navigation_cubit.dart';
import 'package:zippy/domain/state/navigation/navigation_state.dart';
import 'navigation_cubit_test.mocks.dart';

@GenerateMocks([], customMocks: [
  MockSpec<GoRouter>(
    as: #MockGoRouter,
    onMissingStub: OnMissingStub.returnDefault,
  ),
])
void main() {
  late NavigationCubit navigationCubit;
  late MockGoRouter mockRouter;

  setUp(() {
    navigationCubit = NavigationCubit();
    mockRouter = MockGoRouter();
    when(mockRouter.go(any)).thenAnswer((_) {});
  });

  tearDown(() {
    navigationCubit.close();
  });

  group('NavigationCubit Tests', () {
    test('initial state has home tab selected', () {
      expect(
        navigationCubit.state,
        equals(const NavigationState(selectedTab: NavigationTab.home)),
      );
    });

    blocTest<NavigationCubit, NavigationState>(
      'setTab updates state and navigates to history',
      build: () => navigationCubit,
      act: (cubit) => cubit.setTab(NavigationTab.history, mockRouter),
      expect: () => [
        const NavigationState(selectedTab: NavigationTab.history),
      ],
      verify: (_) {
        verify(mockRouter.go('/dashboard/history')).called(1);
      },
    );

    blocTest<NavigationCubit, NavigationState>(
      'setTab updates state and navigates to transfer',
      build: () => navigationCubit,
      act: (cubit) => cubit.setTab(NavigationTab.transfer, mockRouter),
      expect: () => [
        const NavigationState(selectedTab: NavigationTab.transfer),
      ],
      verify: (_) {
        verify(mockRouter.go('/dashboard/transfer')).called(1);
      },
    );

    blocTest<NavigationCubit, NavigationState>(
      'setTab updates state and navigates to home',
      build: () => navigationCubit,
      act: (cubit) => cubit.setTab(NavigationTab.home, mockRouter),
      expect: () => [
        const NavigationState(selectedTab: NavigationTab.home),
      ],
      verify: (_) {
        verify(mockRouter.go('/dashboard')).called(1);
      },
    );

    blocTest<NavigationCubit, NavigationState>(
      'setTab updates state for offers tab without navigation',
      build: () => navigationCubit,
      act: (cubit) => cubit.setTab(NavigationTab.offers, mockRouter),
      expect: () => [
        const NavigationState(selectedTab: NavigationTab.offers),
      ],
      verify: (_) {
        verifyNever(mockRouter.go(any));
      },
    );

    blocTest<NavigationCubit, NavigationState>(
      'setTab updates state for support tab without navigation',
      build: () => navigationCubit,
      act: (cubit) => cubit.setTab(NavigationTab.support, mockRouter),
      expect: () => [
        const NavigationState(selectedTab: NavigationTab.support),
      ],
      verify: (_) {
        verifyNever(mockRouter.go(any));
      },
    );

    blocTest<NavigationCubit, NavigationState>(
      'multiple tab changes emit correct states and trigger correct navigations',
      build: () => navigationCubit,
      act: (cubit) {
        cubit.setTab(NavigationTab.history, mockRouter);
        cubit.setTab(NavigationTab.transfer, mockRouter);
        cubit.setTab(NavigationTab.home, mockRouter);
      },
      expect: () => [
        const NavigationState(selectedTab: NavigationTab.history),
        const NavigationState(selectedTab: NavigationTab.transfer),
        const NavigationState(selectedTab: NavigationTab.home),
      ],
      verify: (_) {
        verifyInOrder([
          mockRouter.go('/dashboard/history'),
          mockRouter.go('/dashboard/transfer'),
          mockRouter.go('/dashboard'),
        ]);
      },
    );
  });
}
