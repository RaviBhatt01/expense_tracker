// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:cloud_firestore/cloud_firestore.dart' as _i974;
import 'package:expense_tracker/features/expenses/data/datasources/expense_datasource.dart'
    as _i576;
import 'package:expense_tracker/features/expenses/data/datasources/firebase_expense_datasource.dart'
    as _i153;
import 'package:expense_tracker/features/expenses/data/repositories/expense_repository_impl.dart'
    as _i165;
import 'package:expense_tracker/features/expenses/domain/repositories/expense_repository.dart'
    as _i476;
import 'package:expense_tracker/features/expenses/domain/usecases/add_expense.dart'
    as _i638;
import 'package:expense_tracker/features/expenses/domain/usecases/delete_expense.dart'
    as _i575;
import 'package:expense_tracker/features/expenses/domain/usecases/get_expenses.dart'
    as _i207;
import 'package:expense_tracker/features/expenses/domain/usecases/update_expense.dart'
    as _i563;
import 'package:expense_tracker/features/expenses/presentation/cubit/expense_cubit.dart'
    as _i7;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i576.ExpenseDatasource>(
      () => _i153.FirebaseExpenseDatasource(gh<_i974.FirebaseFirestore>()),
    );
    gh.lazySingleton<_i476.ExpenseRepository>(
      () => _i165.ExpenseRepositoryImpl(
        datasource: gh<_i576.ExpenseDatasource>(),
      ),
    );
    gh.factory<_i638.AddExpenseUseCase>(
      () => _i638.AddExpenseUseCase(repository: gh<_i476.ExpenseRepository>()),
    );
    gh.factory<_i575.DeleteExpenseUseCase>(
      () =>
          _i575.DeleteExpenseUseCase(repository: gh<_i476.ExpenseRepository>()),
    );
    gh.factory<_i207.GetExpensesUseCase>(
      () => _i207.GetExpensesUseCase(repository: gh<_i476.ExpenseRepository>()),
    );
    gh.factory<_i563.UpdateExpenseUseCase>(
      () =>
          _i563.UpdateExpenseUseCase(repository: gh<_i476.ExpenseRepository>()),
    );
    gh.factory<_i7.ExpenseCubit>(
      () => _i7.ExpenseCubit(
        addExpense: gh<_i638.AddExpenseUseCase>(),
        getExpenses: gh<_i207.GetExpensesUseCase>(),
        updateExpense: gh<_i563.UpdateExpenseUseCase>(),
        deleteExpense: gh<_i575.DeleteExpenseUseCase>(),
      ),
    );
    return this;
  }
}
