#Использовать logos

///////////////////////////////////////////////////////////////////////////////
//
// Служебный модуль с набором служебных параметров приложения
//
// При создании нового приложения обязательно внести изменение
// в ф-ии ИмяПродукта, указав имя вашего приложения.
//
// При выпуске новой версии обязательно изменить ее значение
// в ф-ии ВерсияПродукта
//
///////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////
// СВОЙСТВА ПРОДУКТА
///////////////////////////////////////////////////////////////////////////////

// ВерсияПродукта
//	Возвращает текущую версию продукта
//
// Возвращаемое значение:
//   Строка   - Значение текущей версии продукта
//
Функция ВерсияПродукта() Экспорт
	
	Возврат "24.03";
	
КонецФункции // ВерсияПродукта

// ИмяПродукта
//	Возвращает имя продукта
//
// Возвращаемое значение:
//   Строка   - Значение имени продукта
//
Функция ИмяПродукта() Экспорт
	
	Возврат "precommit4onec";
	
КонецФункции // ИмяПродукта

// ПутьКИсполняемомуФайлу
//	Возвращает путь к исполняемому файлу
//
// Возвращаемое значение:
//   Строка   - Путь к исполняемому файлу скрипта
//
Функция ПутьКИсполняемомуФайлу() Экспорт
	
	Возврат ОбъединитьПути(ПутьКРодительскомуКаталогу(), "src", "main.os");
	
КонецФункции // ПутьКИсполняемомуФайлу

// ПутьКРодительскомуКаталогу
//	Возвращает путь к каталогу основного скрипта
//
// Возвращаемое значение:
//   Строка   - Путь к каталогу основного скрипта
//
Функция ПутьКРодительскомуКаталогу() Экспорт
	
	Файл = Новый Файл(ОбъединитьПути(ТекущийСценарий().Каталог, "..", ".."));
	Возврат Файл.ПолноеИмя;
	
КонецФункции // ПутьКРодительскомуКаталогу

// КаталогСценариев
//	Возвращает путь к каталогу сценариев
//
// Возвращаемое значение:
//   Строка   - Путь к каталогу сценариев
//
Функция КаталогСценариев() Экспорт
	
	Возврат ОбъединитьПути(ПутьКРодительскомуКаталогу(), "src", "СценарииОбработки");
	
КонецФункции // КаталогСценариев

///////////////////////////////////////////////////////////////////////////////
// ЛОГИРОВАНИЕ
///////////////////////////////////////////////////////////////////////////////

//	Форматирование логов
//   См. описание метода "УстановитьРаскладку" библиотеки logos
//
Функция Форматировать(Знач Уровень, Знач Сообщение) Экспорт
	
	Возврат СтрШаблон("%1: %2 - %3", ТекущаяДата(), УровниЛога.НаименованиеУровня(Уровень), Сообщение);
	
КонецФункции

// ИмяЛогаСистемы
//	Возвращает идентификатор лога приложения
//
// Возвращаемое значение:
//   Строка   - Значение идентификатора лога приложения
//
Функция ИмяЛогаСистемы() Экспорт
	
	Возврат "oscript.app." + ИмяПродукта();
	
КонецФункции // ИмяЛогаСистемы

///////////////////////////////////////////////////////////////////////////////
// НАСТРОЙКА КОМАНД
///////////////////////////////////////////////////////////////////////////////

// Возвращает имя команды "version" (ключ командной строки)
//
//  Возвращаемое значение:
//   Строка - имя команды
//
Функция ИмяКомандыВерсия() Экспорт
	
	Возврат "version";
	
КонецФункции // ИмяКомандыВерсия

// Возвращает имя команды "help" (ключ командной строки)
//
//  Возвращаемое значение:
//   Строка - имя команды
//
Функция ИмяКомандыПомощь() Экспорт
	
	Возврат "help";
	
КонецФункции // ИмяКомандыПомощь()

// ИмяКомандыПоУмолчанию
// 	Одна из команд может вызываться неявно, без указания команды.
// 	Иными словами, здесь указывается какой обработчик надо вызывать, если приложение запущено без какой-либо команды
// 	myapp /home/user/somefile.txt будет аналогично myapp default-action /home/user/somefile.txt
//
// Возвращаемое значение:
// 	Строка - имя команды по умолчанию
Функция ИмяКомандыПоУмолчанию() Экспорт
	
	Возврат "precommit";
	
КонецФункции // ИмяКомандыПоУмолчанию

// НастроитьКомандыПриложения
//	Регистрирует классы обрабатывающие команды приложения
//
// Параметры:
//	Приложение - Модуль - Модуль менеджера приложения
Процедура НастроитьКомандыПриложения(Знач Приложение) Экспорт
	
	Приложение.ДобавитьКоманду(ИмяКомандыПомощь(), "КомандаСправкаПоПараметрам", "Выводит справку по командам");
	Приложение.ДобавитьКоманду(ИмяКомандыВерсия(), "КомандаVersion", "Выводит версию приложения");
	Приложение.ДобавитьКоманду("precommit", "КомандаПрекоммит", "Выполняет сценарии precommit");
	Приложение.ДобавитьКоманду("install", "КомандаИнсталл",
		"Выполняет подключение (установку) precommit hook'а в репозиторий");
	Приложение.ДобавитьКоманду("configure", "КомандаКонфигуратион", "Выполняет настройку репозитория");
	Приложение.ДобавитьКоманду("exec-rules", "КомандаВыполнитьСценарии",
		"Выполняет указанные сценарии в каталоге репозитория принудительно, без обращения к git");
	
КонецПроцедуры // ПриРегистрацииКомандПриложения
