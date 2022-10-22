-- Разработка интернет-магазина на Spring Framework (урок 1, дз)
-- 
-- Ниже представлен прототип SQL-схемы для интернет-магазина. В рамках данного курса я решил идти от реального кейса,
-- спарсил данные с сайта lavtorg.ru (около 1600 позиций). Сайт слабоструктурирован, поэтому данные необходимо приводить
-- к нормальной форме. Это очень ресурсоёмкий процесс, однако в ходе работы выкристализовывается реальная, рабочая
-- структура БД.
--
-- Работа с 1600 товарных позиций, безусловно, лишь отчасти даст возможность прочувствовать специфику работы с живыми
-- данными, однако это лучше десятка тестовых данных. Сами данные до конца не очищены, тем не менее, некий каркас уже
-- виден. На данном этапе я сознательно не добавляю роли и пользователей, потому как в приоритете все-таки товары и
-- описание оптимальных хранилищ под них.
--
-- На этом этапе SQL-запросы написаны под MySQL (это мой рабочий инструмент, в нем я и занимаюсь очисткой и подготовкой
-- данных для учебного проекта), позже планирую перенести данные в PostreSQL.
--
-- Таблица товарой является ключевой. Часть данных вынесена в таблицы-справочники (виды упаковки, сорта, производители)

CREATE TABLE IF NOT EXISTS `container_types` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `container` varchar(100) DEFAULT NULL COMMENT 'Упаковка',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Виды упаковки (справочник)';

CREATE TABLE IF NOT EXISTS `grades` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `grade_name` varchar(100) DEFAULT NULL COMMENT 'Сорт',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Сорта (справочник)';

-- Информацию о странах (потенциально предполагаю фильтры по стране производителя) буду хранить в отдельном справочнике...

CREATE TABLE IF NOT EXISTS `countries` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `country_name` varchar(100) DEFAULT NULL COMMENT 'Название страны',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Страны (справочник)';

-- ... при этом связь стран с производителями идет через таблицу муниципалитетов. Так, если я знаю, что товары
-- производятся в Мурманске, то по через город я смогу выйти на страну. Если информации о муниципалитете нет, то
-- предполагаю заполнять таблицу названиями стран.

CREATE TABLE IF NOT EXISTS `municipalities` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `country_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Страна, FK: countries.id',
  `municipality_name` varchar(100) DEFAULT NULL COMMENT 'Название мунициплитета (города, села, района)',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Муниципалитеты (справочник)';

-- Таблица производителей. Возможно, позже будет расширена адресами, телефонами, логотипами, пока самое основное

CREATE TABLE IF NOT EXISTS `manufacturers` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `municipality_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Муниципалитет, FK: municipalities.id',
  `manufacturer` varchar(100) DEFAULT NULL COMMENT 'Производитель',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Производители';

-- Категории товаров

CREATE TABLE IF NOT EXISTS `categories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `parent_category_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Муниципалитет, FK: municipalities.id',
  `category` varchar(100) DEFAULT NULL COMMENT 'Категория товара',
  PRIMARY KEY (`id`),
  KEY (`parent_category_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Категории товаров';

-- Названия товаров можно условно разделить на две части. Первая - "общее" наименование товара ("зелёный горошек",
-- "сгущеное молоко", "варенье из айвы"). Так как при росте числа позиций в магазине эта часть названия начинает
-- дублироваться, вынес ее в отдельную таблицу. Это позволит унифицировать наименования товаров, избежать двойного
-- заведения товара

CREATE TABLE IF NOT EXISTS `goods_titles` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `title` varchar(100) DEFAULT NULL COMMENT 'Наименование товара',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Наименования товаров';

-- Помимо общего наименования товара есть БРЕНД (это вторая часть названия), они также вынесены в отдельную таблицу:

CREATE TABLE IF NOT EXISTS `brands` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `brand_name` varchar(100) DEFAULT NULL COMMENT 'Бренды',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Бренды';

-- Бренды и производители, судя по данным, с которыми мне довелось работать, находятся в отношении многие-ко-многим,
-- поэтому для того, чтобы ограничить возможность связывать любые бренды с любыми производителями, добавляю
-- промежуточную таблицу:

CREATE TABLE IF NOT EXISTS `brands_to_manufacturers` (
  `brands_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Бренд, FK: brands.id',
  `manufacturers_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Производитель, FK: manufacturers.id',
  UNIQUE KEY (`brands_id`, `manufacturers_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Бренды к производителям';

-- Таблица товаров:

CREATE TABLE IF NOT EXISTS `goods` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  -- внешние ключи
  `good_title_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Наименование товара, FK: brands.id',
  `brand_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Бренд, FK: brands.id',
  `category_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Категория товара, FK: categories.id',
  `manufacturer_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Производитель, FK: manufacturers.id',
  `grade_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Сорт, FK: grades.id',
  -- характеристики товара
  `main_ingredient_weight` int unsigned DEFAULT NULL COMMENT 'Масса основного продукта (г)',
  `mass_fraction` text COMMENT 'Массовая доля',
  `ingredients` text COMMENT 'Состав',
  `proteins` decimal(5,2) unsigned DEFAULT NULL COMMENT 'Белки',
  `fat` decimal(5,2) unsigned DEFAULT NULL COMMENT 'Жиры',
  `carbohydrates` decimal(5,2) unsigned DEFAULT NULL COMMENT 'Углеводы',
  `energy` varchar(255) DEFAULT NULL COMMENT 'Энергетическая ценность (ккал)',
  -- набор полей-флагов
  `sterilized` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Стерилизованный продукт (да/нет)',
  `gmo_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без ГМО (да/нет)',
  `gluten_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без глютена (да/нет)',
  `starch_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без крахмала (да/нет)',
  `food_supplement_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без пищевых добавок (да/нет)',
  `cholesterol_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без холестерина (да/нет)',
  `preservatives_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без консервантов (да/нет)',
  `dyes_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без искусственных красителей (да/нет)',
  `flavoring_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без ароматизаторов (да/нет)',
  `thickener_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без загустителей (да/нет)',
  `sugar_free` tinyint unsigned NOT NULL DEFAULT '0' COMMENT 'Без сахара (да/нет)',
  -- рекомендации для покупателей о том, как использовать товар
  `recommendations` text COMMENT 'Рекомендации',
  `details` text COMMENT 'Комментарий',
  -- ссылки на изображение и превью
  `img_url` varchar(255) DEFAULT NULL,
  `img_tmb_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1646 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Анализ данных показал также, что один и тот же товар может быть представлен в разной упаковке и разном объеме,
-- нет смысла дублировать общие данные, и специфическая информация вынесена в отдельную таблицу:

CREATE TABLE IF NOT EXISTS `goods_versions` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  -- ссылка на товар
  `good_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Товар (общая информация), FK: goods.id',
  `container_type_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Упаковка, FK: container_types.id',
  -- характерная для конкретной упаковки информация
  `gross_weight` int unsigned DEFAULT NULL COMMENT 'Вес (брутто, г)',
  `net_weight` int unsigned DEFAULT NULL COMMENT 'Вес (нетто, г)',
  `main_ingredient_weight` int unsigned DEFAULT NULL COMMENT 'Масса основного продукта (г)',
  `nominal_volume` int unsigned DEFAULT NULL COMMENT 'Номинальный объём (мл)',
  `pack` int unsigned DEFAULT NULL COMMENT 'Упаковка (шт.)',
  `store` text COMMENT 'Срок хранения',
  -- специфические рекомендации для покупателей о том, как использовать товар
  `recommendations` text COMMENT 'Рекомендации',
  `details` text COMMENT 'Комментарий',
  -- ссылки на изображение и превью
  `img_url` varchar(255) DEFAULT NULL,
  `img_tmb_url` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1646 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- Производство продуктов питания регламентируется стандартами (ГОСТами, техническими условиями), при этом связь
-- между продуктами и стандартами - многие-ко-многим. Поэтому для хранения стандартов нужны три таблицы:

CREATE TABLE IF NOT EXISTS `standard_types` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `standard_type` varchar(50) DEFAULT NULL COMMENT 'Тип стандарта', -- ГОСТ, ТУ, ISO...
  PRIMARY KEY (`id`),
  UNIQUE KEY (`standard_type`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Типы стандартов';

CREATE TABLE IF NOT EXISTS `standards` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT COMMENT 'PK',
  `standard_type_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Тип стандарта, FK: standard_types.id',
  `standard_code` varchar(50) DEFAULT NULL COMMENT 'Код стандарта',
  `standard_name` varchar(200) DEFAULT NULL COMMENT 'Наименование стандарта',
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Бренды';

-- Бренды и производители, судя по данным, с которыми мне довелось работать, находятся в отношении многие-ко-многим,
-- поэтому для того, чтобы ограничить возможность связывать любые бренды с любыми производителями, добавляю
-- промежуточную таблицу:

CREATE TABLE IF NOT EXISTS `standards_to_goods` (
  `standard_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Стандарт, FK: standards.id',
  `good_id` bigint unsigned NULL DEFAULT NULL COMMENT 'Товар, FK: goods.id',
  UNIQUE KEY (`standard_id`, `good_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci COMMENT 'Стандарты к товарам';
