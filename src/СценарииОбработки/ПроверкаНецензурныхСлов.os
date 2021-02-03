///////////////////////////////////////////////////////////////////////////////
// 
// Служебный модуль с реализацией сценариев обработки файлов <ИмяСценария>
//
///////////////////////////////////////////////////////////////////////////////

Перем Лог;

// ИмяСценария
//	Возвращает имя сценария обработки файлов
//
// Возвращаемое значение:
//   Строка   - Имя текущего сценария обработки файлов
//
Функция ИмяСценария() Экспорт
	
	Возврат "ПроверкаНецензурныхСлов";
	
КонецФункции // ИмяСценария()

// ПолучитьСтандартныеНастройкиСценария
//	Возвращает структуру настроек сценария
//
// Возвращаемое значение:
//   Структура   - Структура с настройками сценария
//  	* ИмяСценария	- Строка - Имя, с которым сохранятся настройки
//		* Настройка		- Соответствие - настройки
//
Функция ПолучитьСтандартныеНастройкиСценария() Экспорт
	
	НастройкиСценария = Новый Соответствие;
	НастройкиСценария.Вставить("ИспользоватьПоУмолчанию", Истина);
	НастройкиСценария.Вставить("Версия", "");
	НастройкиСценария.Вставить("КоличествоПопыток", 5);
	НастройкиСценария.Вставить("МассивПараметров", Новый Массив);
	НастройкиСценария.Вставить("ФайлСНецензурнымиСловами", "НецензурныеСлова.txt");

	Возврат Новый Структура("ИмяСценария, Настройка", ИмяСценария(), НастройкиСценария);
	
КонецФункции

// ОбработатьФайл
//	Выполняет обработку файла
//
// Параметры:
//  АнализируемыйФайл		- Файл - Файл из журнала git для анализа
//  КаталогИсходныхФайлов  	- Строка - Каталог расположения исходных файлов относительно каталог репозитория
//  ДополнительныеПараметры - Структура - Набор дополнительных параметров, которые можно использовать 
//  	* Лог  					- Объект - Текущий лог
//  	* ИзмененныеКаталоги	- Массив - Каталоги, которые необходимо добавить в индекс
//		* КаталогРепозитория	- Строка - Адрес каталога репозитория
//		* ФайлыДляПостОбработки	- Массив - Файлы, изменившиеся / образовавшиеся в результате работы сценария
//											и которые необходимо дообработать
//		* ИзмененныеКаталоги	- Массив - Каталоги / файлы которые необходимо добавить в индекс
//
// Возвращаемое значение:
//   Булево   - Признак выполненной обработки файла
//
Функция ОбработатьФайл(АнализируемыйФайл, КаталогИсходныхФайлов, ДополнительныеПараметры) Экспорт

	Лог = ДополнительныеПараметры.Лог;
	НастройкиСценария = ДополнительныеПараметры.Настройки.Получить(ИмяСценария());
	ФайлСНецензурнымиСловами = НастройкиСценария.Получить("ФайлСНецензурнымиСловами");
	// Если конфига нет, то и проверять в общем нечего
	Если НЕ ЗначениеЗаполнено(ФайлСНецензурнымиСловами) Тогда 
		Возврат Ложь;
	Иначе
		Файл = Новый Файл(ФайлСНецензурнымиСловами);
		// Если указан несуществующий файл, то ничего не делаем, но ругнемся в лог
		Если НЕ Файл.Существует() Тогда
			Лог.Предупреждение("Не обнаружен файл с нецензурными словами по пути %1", Файл.ПолноеИмя);
			Возврат Ложь;			
		КонецЕсли;
	КонецЕсли;
	
	// анализ файла без изменения его содержимого
	Если АнализируемыйФайл.Существует() И ТипыФайлов.ЭтоФайлИсходников(АнализируемыйФайл) Тогда
		
		Лог.Информация("Обработка файла '%1' по сценарию '%2'", АнализируемыйФайл.ПолноеИмя, ИмяСценария());
		
		ОбработкаФайла(АнализируемыйФайл.ПолноеИмя, ФайлСНецензурнымиСловами);
		
		Возврат Истина;
		
	КонецЕсли;
		
	Возврат Ложь;
	
КонецФункции // ОбработатьФайл()

Процедура ОбработкаФайла(ИмяФайла, ФайлСНецензурнымиСловами)
	
	СодержимоеФайла = ФайловыеОперации.ПрочитатьТекстФайла(ИмяФайла);
	
	Если Не ЗначениеЗаполнено(СодержимоеФайла) Тогда
		
		Возврат;
	
	Иначе
		
		ПроверкаНаНецензурныеСлова(СодержимоеФайла, ФайлСНецензурнымиСловами);

	КонецЕсли;

	
КонецПроцедуры

Процедура ПроверкаНаНецензурныеСлова(СодержимоеФайла, ФайлСНецензурнымиСловами)

	НовоеСодержимоеФайла = Новый ТекстовыйДокумент;
	
	ТекстРазбора = Новый ТекстовыйДокумент;
	ТекстРазбора.УстановитьТекст(СодержимоеФайла);
	ВсегоСтрок = ТекстРазбора.КоличествоСтрок();

	ПаттернID = ПолучитьСтрокуПатерн(ФайлСНецензурнымиСловами);

	Регексп = Новый РегулярноеВыражение(ПаттернID);
	Регексп.ИгнорироватьРегистр = ИСТИНА;
	Регексп.Многострочный = ИСТИНА;
	
	Для Ит = 1 По ВсегоСтрок Цикл
		
		СтрокаМодуля = ТекстРазбора.ПолучитьСтроку(Ит);
		
		Если Не ПустаяСтрока(СтрокаМодуля) Тогда

			// РазобраннаяСтрока = РазобратьСтроку(СтрокаМодуля);

			ГруппыПоиска = Регексп.НайтиСовпадения(СтрокаМодуля);

			Если ГруппыПоиска.Количество() Тогда

				ТекстОшибки = СтрШаблон("В строке '%1' обнаружены нецензурные слова" + Символы.ПС, Ит);

				Лог.Ошибка(ТекстОшибки);
				ВызватьИсключение ТекстОшибки;

			КонецЕсли;

		КонецЕсли;

	КонецЦикла;

КонецПроцедуры

Функция ПолучитьСтрокуПатерн(ФайлСНецензурнымиСловами)

	ТекстовыйДокумент = Новый ТекстовыйДокумент;
	ТекстовыйДокумент.Прочитать(ФайлСНецензурнымиСловами, КодировкаТекста.UTF8NoBOM);
	КоличествоСтрок = ТекстовыйДокумент.КоличествоСтрок();
	
	Регексп = "(";
	
	Для Ит = 1 По КоличествоСтрок Цикл
			
		Регексп = Регексп + ТекстовыйДокумент.ПолучитьСтроку(Ит) + "|";
	
	КонецЦикла;
	
	Регексп = Лев(СокрЛП(Регексп), СтрДлина(СокрЛП(Регексп))-1) + ")";
		
	Возврат Регексп;
	
КонецФункции