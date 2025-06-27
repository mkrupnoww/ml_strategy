from sklearn.model_selection import RandomizedSearchCV
from sklearn.ensemble import RandomForestClassifier
from sklearn.metrics import classification_report, confusion_matrix
import numpy as np

# Допустим, X_train, X_test, y_train, y_test уже определены ранее.

# Задаем диапазоны для проверки
param_dist = {
    "n_estimators": [100, 300, 500],
    "max_depth": [10, 15, 20, None],
    "min_samples_split": [2, 5, 10],
    "min_samples_leaf": [1, 3, 5],
    "class_weight": ["balanced", "balanced_subsample"]
}

# Инициализация модели
model = RandomForestClassifier(random_state=42, n_jobs=-1)

# RandomizedSearch для проверки комбинаций
search = RandomizedSearchCV(
    model,
    param_dist,
    n_iter=10,           # проверим 10 случайных комбинаций
    scoring="f1",        # оптимизация под F1
    cv=3,                # 3-fold cross-validation
    verbose=2,
    random_state=42,
    n_jobs=-1
)

# Запускаем поиск
search.fit(X_train, y_train)

# Выведем лучшие параметры
print("Лучшие параметры:", search.best_params_)

# Проверим результат модели
best_model = search.best_estimator_
y_pred = best_model.predict(X_test)

print("\nОтчет классификации:\n", classification_report(y_test, y_pred))
print("\nМатрица ошибок:\n", confusion_matrix(y_test, y_pred))

