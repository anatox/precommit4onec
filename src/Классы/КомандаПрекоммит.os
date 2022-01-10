///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с реализацией работы команды <precommit>
//
// (с) BIA Technologies, LLC
//
///////////////////////////////////////////////////////////////////////////////

#Использовать gitrunner

Перем Лог;
Перем РепозиторийGit;

///////////////////////////////////////////////////////////////////////////////

Процедура НастроитьКоманду(Знач Команда, Знач Парсер) Экспорт
	
	// Добавление параметров команды
	Парсер.ДобавитьПозиционныйПараметрКоманды(Команда, "КаталогРепозитория", "Каталог анализируемого репозитория");
	Парсер.ДобавитьИменованныйПараметрКоманды(Команда, "-source-dir",
		"Каталог расположения исходных файлов относительно корня репозитория. По умолчанию <src>");
	
КонецПроцедуры // НастроитьКоманду

// Выполняет логику команды
//
// Параметры:
//   ПараметрыКоманды - Соответствие - Соответствие ключей командной строки и их значений
//   Приложение - Модуль - Модуль менеджера приложения
//
Функция ВыполнитьКоманду(Знач ПараметрыКоманды, Знач Приложение) Экспорт
	
	Лог = Приложение.ПолучитьЛог();
    	НастройкиИБ = Приложение.ПолучитьНастройкиИБ();
	
	КаталогРепозитория = ПараметрыКоманды["КаталогРепозитория"];
	КаталогИсходныхФайлов = ПараметрыКоманды["-source-dir"];
	
	Если НЕ ПроверитьПараметрыКоманды(КаталогРепозитория, Лог) Тогда
		
		Возврат Приложение.РезультатыКоманд().НеверныеПараметры;
		
	КонецЕсли;
	
	Если Не ЗначениеЗаполнено(КаталогИсходныхФайлов) Тогда
		
		КаталогИсходныхФайлов = "src";
		
	КонецЕсли;
	
	ТекущийКаталогИсходныхФайлов = ОбъединитьПути(КаталогРепозитория, КаталогИсходныхФайлов);
	ФайлТекущийКаталогИсходныхФайлов = Новый Файл(ТекущийКаталогИсходныхФайлов);
	ТекущийКаталогИсходныхФайлов = ФайлТекущийКаталогИсходныхФайлов.ПолноеИмя;
	
	Если НЕ ФайлТекущийКаталогИсходныхФайлов.Существует() Тогда
		
		СоздатьКаталог(ТекущийКаталогИсходныхФайлов);
		
	КонецЕсли;
	
	УправлениеНастройками = МенеджерНастроек.НастройкиРепозитория(КаталогРепозитория);
	НаборНастроек = СценарииОбработки.ПолучитьСценарииСПараметрамиВыполнения(КаталогРепозитория);
	ЖурналИзменений = ПолучитьЖурналИзменений();
	
	ПараметрыОбработки = СценарииОбработки.ПолучитьСтандартныеПараметрыОбработки();
	ПараметрыОбработки.Лог = Лог;
	ПараметрыОбработки.КаталогРепозитория = КаталогРепозитория;
	ПараметрыОбработки.ТекущийКаталогИсходныхФайлов = ТекущийКаталогИсходныхФайлов;
	ПараметрыОбработки.НастройкиИБ = НастройкиИБ;

	ФайлыКОбработке = Новый ТаблицаЗначений();
	ФайлыКОбработке.Колонки.Добавить("Файл");
	ФайлыКОбработке.Колонки.Добавить("ТипИзменения");
	

	Для каждого Изменение Из ЖурналИзменений Цикл
		ДобавитьКОбработке(ФайлыКОбработке, Новый Файл(ОбъединитьПути(КаталогРепозитория, Изменение.ИмяФайла)), Изменение.ТипИзменения);
	КонецЦикла;
	
	ВыполнитьОбработкуФайлов(ФайлыКОбработке, НаборНастроек, ПараметрыОбработки);
	
	// измененные каталоги необходимо добавить в индекс
	Лог.Отладка("Добавление измененных каталогов в индекс git");
	Для Каждого Каталог Из ПараметрыОбработки.ИзмененныеКаталоги Цикл
		
		РепозиторийGit.ДобавитьФайлВИндекс("""" + Каталог + """");
		
	КонецЦикла;
	
	// При успешном выполнении возвращает код успеха
	Возврат Приложение.РезультатыКоманд().Успех;
	
КонецФункции // ВыполнитьКоманду

///////////////////////////////////////////////////////////////////////////////
Процедура ДобавитьКОбработке(СпиоскФ, ДобавляемыйФ, ТипИзменения)
	Строка = СпиоскФ.Добавить();
	Строка.Файл = ДобавляемыйФ;
	Строка.ТипИзменения = ТипИзменения;
КонецПроцедуры

Процедура ВыполнитьОбработкуФайлов(Файлы, НаборНастроек, ПараметрыОбработки)
	
	КаталогРепозитория = ПараметрыОбработки.КаталогРепозитория;
	Ит = 0;
	Пока Ит < Файлы.Количество() Цикл
		
		АнализируемыйФайл = Файлы[Ит].Файл;
		Лог.Отладка("Анализируется файл <%1>", АнализируемыйФайл.Имя);
		
		ИмяФайла = ФайловыеОперации.ПолучитьНормализованныйОтносительныйПуть(КаталогРепозитория,
				СтрЗаменить(АнализируемыйФайл.ПолноеИмя, КаталогРепозитория, ""));
		
		ИмяПроекта = МенеджерНастроек.ИмяПроектаДляФайла(ИмяФайла);
		
		НастройкаОбработки = НаборНастроек[ИмяПроекта];
		
		Если НЕ ЗначениеЗаполнено(НастройкаОбработки) Тогда
			
			ВызватьИсключение СтрШаблон("Не удалось получить настройки для %1", ИмяФайла);
			
		КонецЕсли;
		
		СценарииОбработкиФайлов = НастройкаОбработки.СценарииОбработки;
		НастройкиСценариев = НастройкаОбработки.НастройкиСценариев;
		
		ПараметрыОбработки.Настройки = НастройкиСценариев.Получить("НастройкиСценариев");
		
		ПараметрыОбработки.ТипИзменения = Файлы[Ит].ТипИзменения;

		Для Каждого СценарийОбработки Из СценарииОбработкиФайлов Цикл
			
			ФайлОбработан = СценарийОбработки.ОбработатьФайл(АнализируемыйФайл,
					ПараметрыОбработки.ТекущийКаталогИсходныхФайлов,
					ПараметрыОбработки);
			
			Если НЕ ФайлОбработан Тогда
				Продолжить;
			КонецЕсли;
			
			Для Каждого ФайлДляДопОбработки Из ПараметрыОбработки.ФайлыДляПостОбработки Цикл
				
				ДобавитьКОбработке(Файлы, ФайловыеОперации.НовыйФайл(ФайлДляДопОбработки), ВариантИзмененийФайловGit.Изменен);
				
			КонецЦикла;
			
			ПараметрыОбработки.ФайлыДляПостОбработки.Очистить();
			
		КонецЦикла;
		
		Ит = Ит + 1;
		
	КонецЦикла;
	
КонецПроцедуры
///////////////////////////////////////////////////////////////////////////////

Функция ПроверитьПараметрыКоманды(КаталогРепозитория, Лог)
	
	ФайлКаталогРепозитория = Новый Файл(КаталогРепозитория);
	
	Если НЕ ФайлКаталогРепозитория.Существует() ИЛИ ФайлКаталогРепозитория.ЭтоФайл() Тогда
		
		Лог.Ошибка("Каталог репозитория '%1' не существует или это файл", КаталогРепозитория);
		Возврат Ложь;
		
	КонецЕсли;
	
	КаталогРепозитория = ФайлКаталогРепозитория.ПолноеИмя;
	
	РепозиторийGit = Новый ГитРепозиторий();
	РепозиторийGit.УстановитьРабочийКаталог(КаталогРепозитория);
	
	Если НЕ РепозиторийGit.ЭтоРепозиторий() Тогда
		
		Лог.Ошибка("Каталог '%1' не является репозиторием git", КаталогРепозитория);
		Возврат Ложь;
		
	КонецЕсли;
	
	Возврат Истина;
	
КонецФункции

Функция ПолучитьЖурналИзменений()
	
	ПараметрыКомандыGit = Новый Массив;
	ПараметрыКомандыGit.Добавить("diff --name-status --staged --no-renames");
	РепозиторийGit.ВыполнитьКоманду(ПараметрыКомандыGit);
	РезультатВывода = РепозиторийGit.ПолучитьВыводКоманды();
	СтрокиВывода = СтрРазделить(РезультатВывода, Символы.ПС);
	ЖурналИзменений = Новый Массив;
	
	Для Каждого СтрокаВывода Из СтрокиВывода Цикл
		
		Лог.Отладка("	<%1>", СтрокаВывода);
		
		СтрокаВывода = СокрЛП(СтрокаВывода);
		ПозицияПробела = СтрНайти(СтрокаВывода, Символы.Таб);
		СимволИзменения = Лев(СтрокаВывода, 1);
		
		ТипИзменения = ВариантИзмененийФайловGit.ОпределитьВариантИзменения(СимволИзменения);
		ИмяФайла = СокрЛП(СтрЗаменить(Сред(СтрокаВывода, ПозицияПробела + 1), """", ""));
		ЖурналИзменений.Добавить(Новый Структура("ИмяФайла, ТипИзменения", ИмяФайла, ТипИзменения));
		
		Лог.Отладка("		В журнале git %2 файл <%1>", ИмяФайла, ТипИзменения);
		
	КонецЦикла;
	
	Возврат ЖурналИзменений;
	
КонецФункции
