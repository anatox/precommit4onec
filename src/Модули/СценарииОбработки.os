Функция Загрузить(КаталогРепозитория, Проект, Знач ПараметрИменаЗагружаемыхСценариев = Неопределено) Экспорт
	
	ТекущийКаталогСценариев = МенеджерПриложения.КаталогСценариев();
	ВсеЗагруженные = Новый Массив;
	ФайлыГлобальныхСценариев = НайтиФайлы(ТекущийКаталогСценариев, "*.os");
	ФайлыЛокальныхСценариев = Новый Массив;	
	
	Лог = МенеджерПриложения.ПолучитьЛог();
	
	Если ПараметрИменаЗагружаемыхСценариев <> Неопределено Тогда
		
		ИменаЗагружаемыхСценариев = ПараметрИменаЗагружаемыхСценариев;
		
	Иначе
		
		ИменаЗагружаемыхСценариев = МенеджерНастроек.ИменаЗагружаемыхСценариев(Проект);
		
	КонецЕсли;
	
	Если НЕ МенеджерНастроек.ЭтоНовый() Тогда
		
		Лог.Информация("Читаем настройки " + Проект);
		
		ИспользоватьСценарииРепозитория = МенеджерНастроек.ЗначениеНастройки("ИспользоватьСценарииРепозитория", Проект, Ложь);
		
		Если ИспользоватьСценарииРепозитория Тогда
			
			ЛокальныйКаталог = МенеджерНастроек.ЗначениеНастройки("КаталогЛокальныхСценариев", Проект);
			ПутьКЛокальнымСценариям = ОбъединитьПути(КаталогРепозитория, ЛокальныйКаталог);
			ФайлПутьКЛокальнымСценариям = Новый Файл(ПутьКЛокальнымСценариям);
			
			Если Не ФайлПутьКЛокальнымСценариям.Существует() ИЛИ ФайлПутьКЛокальнымСценариям.ЭтоФайл() Тогда
				
				Лог.Ошибка("Сценарии из репозитория не загружены т.к. отсутствует каталог %1", ЛокальныйКаталог);
				
			Иначе
				
				ФайлыЛокальныхСценариев = НайтиФайлы(ФайлПутьКЛокальнымСценариям.ПолноеИмя, "*.os");
				
			КонецЕсли;
			
		КонецЕсли;
		
	КонецЕсли;
	
	ЗагрузитьИзКаталога(ВсеЗагруженные, ФайлыГлобальныхСценариев, ИменаЗагружаемыхСценариев);
	ЗагрузитьИзКаталога(ВсеЗагруженные, ФайлыЛокальныхСценариев, , Истина);
	
	Если ВсеЗагруженные.Количество() = 0 Тогда
		
		ВызватьИсключение "Нет доступных сценариев обработки файлов";
		
	КонецЕсли;
	
	Возврат ВсеЗагруженные;
	
КонецФункции

Процедура ЗагрузитьИзКаталога(ВсеЗагруженные, ФайлыСценариев,
		Знач ИменаЗагружаемыхСценариев = Неопределено,
		ЗагрузитьВсе = Ложь) Экспорт
	Лог = МенеджерПриложения.ПолучитьЛог();
	
	Если ИменаЗагружаемыхСценариев = Неопределено Тогда
		
		ИменаЗагружаемыхСценариев = Новый Массив;
		
	КонецЕсли;
	
	Для Каждого ФайлСценария Из ФайлыСценариев Цикл
		
		Если СтрСравнить(ФайлСценария.ИмяБезРасширения, "ШаблонСценария") = 0 Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Если НЕ ЗагрузитьВсе
			И ИменаЗагружаемыхСценариев.Найти(ФайлСценария.Имя) = Неопределено
			И ИменаЗагружаемыхСценариев.Найти(ФайлСценария.ИмяБезРасширения) = Неопределено Тогда
			
			Продолжить;
			
		КонецЕсли;
		
		Попытка
			
			СценарийОбработки = ЗагрузитьСценарий(ФайлСценария.ПолноеИмя);
			ВсеЗагруженные.Добавить(СценарийОбработки);
			
		Исключение
			
			Лог.Ошибка("Ошибка загрузки сценария %1: %2", ФайлСценария.ПолноеИмя, ОписаниеОшибки());
			Продолжить;
			
		КонецПопытки;
		
	КонецЦикла;
	
КонецПроцедуры

Функция ПолучитьСтандартныеПараметрыОбработки() Экспорт
	
	Лог = МенеджерПриложения.ПолучитьЛог();
	
	ПараметрыОбработки = Новый Структура();
	ПараметрыОбработки.Вставить("ФайлыДляПостОбработки", Новый Массив);
	ПараметрыОбработки.Вставить("ИзмененныеКаталоги", Новый Массив);
	ПараметрыОбработки.Вставить("Лог", Лог);
	ПараметрыОбработки.Вставить("КаталогРепозитория", Неопределено);
	ПараметрыОбработки.Вставить("ТекущийКаталогИсходныхФайлов", Неопределено);
	ПараметрыОбработки.Вставить("Настройки", Неопределено);
	ПараметрыОбработки.Вставить("ТипИзменения", ВариантИзмененийФайловGit.Изменен);
	ПараметрыОбработки.Вставить("ЗатребованныеСценарии", Новый Массив);
	ПараметрыОбработки.Вставить("НастройкиИБ", Неопределено);
    
	Возврат ПараметрыОбработки;
	
КонецФункции

// <Возвращает соответствие со сценариями и их настройками>
//
// Параметры:
//   КаталогРепозитория - <Строка> - <Адрес каталога репозитория>
//   ИменаЗагружаемыхСценариев - <Массив.Строка> - <Предназначен для переопределения сценариев,
//													Если задан загрузятся только они >
//
//  Возвращаемое значение:
//   <Соответствие> - <ключ - Ключ структуры настроек прекоммит или
//							путь к каталогу, который обрабатывается
//							нестандартными правилами >
//
Функция ПолучитьСценарииСПараметрамиВыполнения(КаталогРепозитория, ИменаЗагружаемыхСценариев = Неопределено) Экспорт
	
	НастройкиПроектов = МенеджерНастроек.ПроектыКонфигурации();
	НаборНастроек = Новый Соответствие;
	
	Для Каждого ИмяПроекта Из НастройкиПроектов Цикл
		Настройка = НастройкаОбработкиПроекта(ИмяПроекта, КаталогРепозитория, ИменаЗагружаемыхСценариев);
		НаборНастроек.Вставить(ИмяПроекта, Настройка);
	КонецЦикла;
	
	ИмяПроекта = ""; // Базовые настройки
	Настройка = НастройкаОбработкиПроекта(ИмяПроекта, КаталогРепозитория, ИменаЗагружаемыхСценариев);
	НаборНастроек.Вставить(ИмяПроекта, Настройка);
	
	Возврат НаборНастроек;
	
КонецФункции

Функция НастройкаОбработкиПроекта(ИмяПроекта, КаталогРепозитория, Знач ИменаЗагружаемыхСценариев = Неопределено)
	
	Настройка = Новый Структура("СценарииОбработки, НастройкиСценариев");
	Если ИменаЗагружаемыхСценариев = Неопределено Тогда
		ИменаЗагружаемыхСценариев = МенеджерНастроек.ИменаЗагружаемыхСценариев(ИмяПроекта);
	КонецЕсли;
	
	Настройка.СценарииОбработки = СценарииОбработки.Загрузить(КаталогРепозитория,
			ИмяПроекта,
			ИменаЗагружаемыхСценариев);
	
	Настройка.НастройкиСценариев = МенеджерНастроек.НастройкиПроекта(ИмяПроекта);

	НормализоватьНастройкиСценариев(Настройка);
	
	Возврат Настройка;
	
КонецФункции

Функция ПолучитьПараметрыОбработкиФайла(ИмяФайла, НастройкиПроектов) Экспорт
	
	ИмяОбщейНастройки = МенеджерНастроек.КлючНастройкиPrecommit();
	НайденнаяНастройка = НастройкиПроектов.Получить(ИмяОбщейНастройки);
	
	Для Каждого ЭлементНастройки Из НастройкиПроектов Цикл
		
		Если ЭлементНастройки.Ключ = ИмяОбщейНастройки Тогда
			
			Продолжить;
			
		ИначеЕсли СтрНачинаетсяС(ИмяФайла, ЭлементНастройки.Ключ) Тогда
			
			НайденнаяНастройка = ЭлементНастройки.Значение;
			
		Иначе
			// ничего
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат НайденнаяНастройка;
	
КонецФункции

Функция ГлобальныеСценарии() Экспорт
	
	Возврат МенеджерНастроек.ПолучитьИменаСценариевКаталога(МенеджерПриложения.КаталогСценариев());
	
КонецФункции

Функция НастройкиГлобальныхСценариев() Экспорт
	
	Возврат НастройкиСценариев(ГлобальныеСценарии(), МенеджерПриложения.КаталогСценариев());
	
КонецФункции

Функция НастройкиСценариев(ИменаСценариев, Знач КаталогСценариев = Неопределено) Экспорт
	
	Если КаталогСценариев = Неопределено Тогда
		
		КаталогСценариев = МенеджерПриложения.КаталогСценариев();
		
	КонецЕсли;
	
	НастройкиСценариев = Новый Соответствие;
	Рефлектор = Новый Рефлектор;
	
	Для Каждого ИмяСценария Из ИменаСценариев Цикл
		
		ОбъектСценария = ЗагрузитьСценарий(ОбъединитьПути(КаталогСценариев, ИмяСценария));
		
		Если Рефлектор.МетодСуществует(ОбъектСценария, "ПолучитьСтандартныеНастройкиСценария") Тогда
			
			СтруктураНастроек = Рефлектор.ВызватьМетод(ОбъектСценария, "ПолучитьСтандартныеНастройкиСценария");
			НастройкиСценариев.Вставить(СтруктураНастроек.ИмяСценария, СтруктураНастроек.Настройка);
			
		КонецЕсли;
		
	КонецЦикла;
	
	Возврат НастройкиСценариев;
	
КонецФункции

Процедура НормализоватьНастройкиСценариев(Настройка)
	
	УзелНастройкиСценариев = Настройка.НастройкиСценариев.Получить("НастройкиСценариев");
	Если УзелНастройкиСценариев = Неопределено Тогда
		УзелНастройкиСценариев = Новый Соответствие;
		Настройка.НастройкиСценариев.Вставить("НастройкиСценариев", УзелНастройкиСценариев);
	КонецЕсли;

	Рефлектор = Новый Рефлектор;
	ИмяМетодаИмяСценария = "ИмяСценария";
	
	Для Каждого СценарийОбработки Из Настройка.СценарииОбработки Цикл
		ИмяСценария = "";
		Если Рефлектор.МетодСуществует(СценарийОбработки, ИмяМетодаИмяСценария) Тогда
			ИмяСценария = Рефлектор.ВызватьМетод(СценарийОбработки, ИмяМетодаИмяСценария);
		КонецЕсли;
		Если Не ЗначениеЗаполнено(ИмяСценария) Тогда
			Продолжить;
		КонецЕсли;

		Если УзелНастройкиСценариев.Получить(ИмяСценария) = Неопределено Тогда
			УзелНастройкиСценариев.Вставить(ИмяСценария, Новый Соответствие);
		КонецЕсли;
	КонецЦикла;

КонецПроцедуры
