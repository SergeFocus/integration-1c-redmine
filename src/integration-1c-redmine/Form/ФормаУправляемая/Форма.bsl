﻿
&НаСервере
Перем ОбъектЭтойОбработки;

&НаКлиенте
Перем УспешнаяИнициализация;

&НаКлиенте
Перем мПользовательскиеЗапросы;

&НаКлиенте
Перем мТекПозицияВДереве;
&НаКлиенте
Перем мТекПозицияВСписке;

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ И ФУНКЦИИ ОБЩЕГО НАЗНАЧЕНИЯ

&НаКлиенте
// Проверка заполнения реквизитов объекта по переданной структуре элементов
//
Функция ВсеРеквизитыЗаполнены(СтруктураПолей, ИмяДействия = "", Сообщать = Истина, Форма = Неопределено) Экспорт
	
	ВсеЗаполнены = Истина;
	Для каждого Поле из СтруктураПолей Цикл
		Если (Форма = Неопределено И НЕ ЗначениеЗаполнено(Объект[Поле.Ключ])) 
			Или (Форма <> Неопределено И НЕ ЗначениеЗаполнено(Форма[Поле.Ключ])) Тогда
			Если Сообщать Тогда 
				#Если Клиент Тогда
					Сообщение = Новый СообщениеПользователю;
					Сообщение.Текст = "Для выполнения функции: " + ИмяДействия + " - необходимо заполнить поле: " + Поле.Ключ;
					Сообщение.Поле = ?(Форма=Неопределено, "Объект.", "")+Поле.Ключ;
					Сообщение.УстановитьДанные(Объект);
					Сообщение.Сообщить(); 	
				#КонецЕсли
			КонецЕсли;
			ВсеЗаполнены = Ложь;
		КонецЕсли;
	КонецЦикла;
	
	Возврат ВсеЗаполнены;	
КонецФункции

&НаКлиенте
Функция ОбязательныеПоля()
	Возврат "Сервер, Порт," + ?(Объект.БазоваяАутентификация, "Пользователь, Пароль", "APIkey");
КонецФункции


&НаКлиенте
Процедура УстановитьФокус()
	
	Если мТекПозицияВДереве <> Неопределено Тогда
		// Позиционирование в дереве
		ПредПозиционирование = ДеревоПроектовЗадач.НайтиПоИдентификатору(мТекПозицияВДереве);
		Если ПредПозиционирование <> Неопределено Тогда
			Элементы.ДеревоПроектовЗадач.ТекущаяСтрока = ПредПозиционирование;
			//УстановитьОтборСпискаПоДереву(ПредПозиционирование);
		КонецЕсли;
		
		// Позиционирование в списке задач
		Если мТекПозицияВСписке = Неопределено Тогда
			Возврат;
		КонецЕсли;
		
		ПредПозиционирование = Объект.СписокЗадач.НайтиПоИдентификатору(мТекПозицияВСписке);
		Если ПредПозиционирование <> Неопределено Тогда
			Элементы.СписокЗадач.ТекущаяСтрока = ПредПозиционирование;
		КонецЕсли;
	КонецЕсли;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьОтборСпискаПоДереву(Знач ТекСтрокаДерева)
	
	Элементы.СписокЗадач.ОтборСтрок = Новый ФиксированнаяСтруктура("ПолеОтбора", Формат(ТекСтрокаДерева.Идентификатор, "ЧГ=0"));
	
	Объект.СписокЗадач.Сортировать("ПолеСортировки Возр");

КонецПроцедуры

&НаКлиенте
Процедура УстановитьОписаниеЗадачи(ТекстОписания);
	
	//TODO: Проверить конвертер Textile в HTML с IE ниже 9-го  
	Попытка
		Элементы.ОписаниеЗадачиHTML.Документ.getElementById ("txt").innerHTML = ТекстОписания;
		
		// Посылаем сообщение невидимой кнопке, чтобы выполнить команду JS
		Команда = Элементы.ОписаниеЗадачиHTML.Документ.getElementById ("SendEvent");    
		Команда.click("onclick");
		
		// получаем результат из контейнера DIV
		//лРез = Элементы.ОписаниеЗадачиHTML.Документ.getElementById ("BufferData").innerHTML;
	Исключение
	КонецПопытки;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьИнфоОЗатраченномВремениПоЗадаче(ТекСтрока)
	
	УжеЗатрачено = ?(ТекСтрока.ЗатраченоВремени = 0, "Нет данных о затраченом времени", "Уже затрачено: "+Формат(ТекСтрока.ЗатраченоВремени, "ЧЦ=10; ЧДЦ=2; ЧГ=0")+" час(ов)");
	
КонецПроцедуры

////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ФОРМЫ

&НаСервере
Процедура ПриСозданииНаСервере(Отказ, СтандартнаяОбработка)
	
	ДобавитьКнопкуПерезапуска();
	
КонецПроцедуры


&НаКлиенте
Процедура ПриОткрытии(Отказ)
	
	ОбработатьВыборПользователя(КодВозвратаДиалога.Да, Неопределено); // Выполнить инициализацию основных параметров обработки

	УстановитьВидимость();
	УстановитьЗаголовок();
	
	// Поля по умолчанию
	Деятельность = "Development";
	
КонецПроцедуры

&НаКлиенте
Процедура ПриЗакрытии()
	
	// Чистим мусор
	Попытка
		УдалитьФайлы(Объект.ПутьКБиблиотекеФорматированияТекста);
	Исключение
		Сообщить(ОписаниеОшибки());	
	КонецПопытки;
	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ СОБЫТИЙ ЭЛЕМЕНТОВ ФОРМЫ

&НаКлиенте
Процедура ПроектНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ЗаполнитьСписокВыбораПроекта();
КонецПроцедуры

&НаКлиенте
Процедура ИсполнительНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ЗаполнитьСписокВыбораИсполнителейПроекта();
КонецПроцедуры

&НаКлиенте
Процедура ПолеСсылкаНаОбъект1СНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ЗаполнитьСписокВыбораПолеСсылкаНаОбъект1С();	
КонецПроцедуры

&НаКлиенте
Процедура ФорматированиеТекстаНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	
	Элементы.ФорматированиеТекста.СписокВыбора.Очистить();
	
	Элементы.ФорматированиеТекста.СписокВыбора.Добавить("none");
	Элементы.ФорматированиеТекста.СписокВыбора.Добавить("Textile");
	Элементы.ФорматированиеТекста.СписокВыбора.Добавить("Markdown");
	
КонецПроцедуры

&НаКлиенте
Процедура ФорматированиеТекстаПриИзменении(Элемент)
	
	УстановитьОписаниеЗадачиHTML(Истина);
	
КонецПроцедуры

&НаСервере
Процедура УстановитьОписаниеЗадачиHTML(ИзменитьКонвертер = Ложь)
	
	ОписаниеЗадачиHTML = ОбъектЭтойОбработки().ПолучитьТекстИнициализацииКовертераВПолеHTML(ИзменитьКонвертер);
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");

КонецПроцедуры



&НаКлиенте
Процедура СтатусНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ДопВариантыПолей = Новый Массив;
	ДопВариантыПолей.Добавить("open");
	ДопВариантыПолей.Добавить("closed");
	ДопВариантыПолей.Добавить("*");
	
	ЗаполнитьСписокВыбораЭлементаФормы(Элемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ПриоритетНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ЗаполнитьСписокВыбораЭлементаФормы(Элемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ТрекерНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ЗаполнитьСписокВыбораЭлементаФормы(Элемент.Имя);
КонецПроцедуры

&НаКлиенте
Процедура ДеятельностьНачалоВыбораИзСписка(Элемент, СтандартнаяОбработка)
	ЗаполнитьСписокВыбораЭлементаФормы(Элемент.Имя);
КонецПроцедуры

// ДеревоПроектовЗадач

&НаКлиенте
Процедура ДеревоПроектовЗадачПриАктивизацииСтроки(Элемент)
	
	ТекСтрокаДерева = Элементы.ДеревоПроектовЗадач.ТекущиеДанные;
	
	Если ТекСтрокаДерева = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	УстановитьОтборСпискаПоДереву(ТекСтрокаДерева);
	
	// Снимаем флажки
	СнятьФлажки(Неопределено);
	
	мТекПозицияВДереве = ТекСтрокаДерева.ПолучитьИдентификатор();

КонецПроцедуры


// Список задач

&НаКлиенте
Процедура СписокЗадачПриАктивизацииСтроки(Элемент)
	
	ТекСтрокаСписка = Элементы.СписокЗадач.ТекущиеДанные;
	Если ТекСтрокаСписка = Неопределено Тогда
		Возврат;
	КонецЕсли;	
	
	мНомерЗадачи = Формат(ТекСтрокаСписка.Идентификатор,"ЧГ=0");
	
	Если ПоказатьДополнительнуюПанель Тогда
		УстановитьОписаниеЗадачи(ТекСтрокаСписка.Описание);
	КонецЕсли;
	
	//Если ЭлементыФормы.ДополнительнаяПанель.Страницы.История.Раскрыта Тогда
	//	ВывестиИсториюИзмененийЗадачи(мНомерЗадачи);
	//КонецЕсли;
	
	УстановитьИнфоОЗатраченномВремениПоЗадаче(ТекСтрокаСписка);
	
	Если мТекПозицияВСписке <> ТекСтрокаСписка.ПолучитьИдентификатор() Тогда
		мТекПозицияВСписке = ТекСтрокаСписка.ПолучитьИдентификатор();
	КонецЕсли;

КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеОЗатраченномВремениПоЗадаче(НомерЗадачи)
	
	мПараметры = "&issue_id="+НомерЗадачи;
	ДанныеОВремени = ОбъектЭтойОбработки().ПолучитьДанныеРесурсаИзТрекера("time_entries", мПараметры, Ложь);
	
	Если ОбъектЭтойОбработки().ОтчетоВыполнении.ЕстьОшибки Тогда
		Возврат Новый Массив;
	КонецЕсли;

	Возврат ДанныеОВремени["time_entries"];
КонецФункции


&НаКлиенте
Процедура ЗаполнитьСписокВыбораПроекта()
	
	Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля()), "Заполнение списка проектов") Тогда
		Возврат;
	КонецЕсли;
	
	СписокПроектов = ПолучитьСписокПроектовИзТрекера();
	
	Если Объект.ОтчетОвыполнении.ЕстьОшибки Тогда
		ПоказатьСообщениеПользователю("Проект", ЭтаФорма, Объект.ОтчетОВыполнении.ТекстОшибки);
	КонецЕсли; 
	
	Элементы.Проект.СписокВыбора.Очистить();
	Для Каждого ДанныеПроекта Из СписокПроектов Цикл
		Если ДанныеПроекта["STATUS"] = 1 Тогда // открытые проекты
			Элементы.Проект.СписокВыбора.Добавить(ДанныеПроекта["name"]);
		КонецЕсли;	
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ПерезаполнитьСписокЗапросов()
	
	Данные = Объект.ЗагруженныеДанные.Получить("queries");
	Если Данные = Неопределено Тогда
		Возврат;
	КонецЕсли;
	
	Если ЗначениеЗаполнено(Проект) Тогда
		мПроект = ПолучитьИдентификаторПараметра(Проект, "projects");
	КонецЕсли;
	
	Если мПользовательскиеЗапросы = Неопределено Тогда
		мПользовательскиеЗапросы = Новый СписокЗначений;
	Иначе
		Для Каждого Кнопка Из мПользовательскиеЗапросы Цикл
			УдалитьКнопкуИзФормы(Кнопка.Значение);	
		КонецЦикла;
	КонецЕсли;
	
	Для Каждого Запрос Из Данные["queries"] Цикл
		Если НЕ Запрос.Свойство("project_id") Тогда
			мПользовательскиеЗапросы.Добавить("Запрос_"+Формат(Запрос.id, "ЧГ=0"), Запрос.name);
		КонецЕсли;
		Если мПроект <> Неопределено И Запрос.Свойство("project_id") И Запрос.project_id = мПроект Тогда
			мПользовательскиеЗапросы.Добавить("Запрос_"+Формат(Запрос.id, "ЧГ=0"), Запрос.name);	
		КонецЕсли;
	КонецЦикла;
	
	Для Каждого Кнопка Из мПользовательскиеЗапросы Цикл
		ДобавитьКнопкуНаФорму(Кнопка.Значение, Кнопка.Представление, "ОбновитьСписокЗадачПоЗапросу", "Запросы",, БиблиотекаКартинок.СтартБизнесПроцесса);
	КонецЦикла;

КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокЗадачПоЗапросу(Кнопка)
	
	ИдЗапроса = Число(Прав(Кнопка.Имя, СтрДлина(Кнопка.Имя) - 14));
	
	ОбновитьСписокЗадач(Неопределено);

КонецПроцедуры

&НаСервере
Функция ПолучитьИдентификаторПараметра(Параметр, Ресурс)
	Возврат ОбъектЭтойОбработки().ПолучитьИдентификаторПараметра(Параметр, Ресурс);	
КонецФункции







&НаСервере
// Параметры:
//  Элементы               - ВсеЭлементыФормы
//  Команды               - КомандыФормы
//  ИмяКнопки               - Строка
//  Синоним               - Строка
//  ИмяДействия           - Строка
//  ГруппаРодитель           - ГруппаФормы (По умолчанию = Неопределено)
//  ТолькоВоВсехДействиях - Булево (По умолчанию = Ложь)
//  Картинка               - Картинка (По умолчанию = Неопределено)
//  Пометка               - Булево (По умолчанию = Ложь) 
//
Процедура ДобавитьКнопкуНаФорму(ИмяКнопки, Синоним, ИмяДействия, Подменю, ТолькоВоВсехДействиях = Ложь, Картинка = Неопределено, Пометка = Ложь)

    ИмяКоманды = "Команда" + ИмяКнопки;
    
    // Добавляем новую команду обработки выбора вида операции.
    Команда = Команды.Добавить(ИмяКоманды);
    Команда.Действие = ИмяДействия;
    Если Картинка <> Неопределено Тогда
        Команда.Картинка = Картинка;
    КонецЕсли;
    
	НоваяКнопка = Элементы.Добавить(ИмяКнопки, Тип("КнопкаФормы"), Элементы[Подменю]);
	
    НоваяКнопка.Вид						= ВидКнопкиФормы.КнопкаКоманднойПанели;
    НоваяКнопка.ИмяКоманды				= ИмяКоманды;
    НоваяКнопка.Заголовок				= Синоним;
    НоваяКнопка.ТолькоВоВсехДействиях	= ТолькоВоВсехДействиях;
    НоваяКнопка.Пометка					= Пометка;

КонецПроцедуры // ДобавитьКнопкуНаФорму()

&НаСервере
Процедура УдалитьКнопкуИзФормы(ИмяКнопки)
	
	Команда = Команды.Найти(ИмяКнопки);
	Команды.Удалить(Команда);
	
	Элемент = Элементы.Найти(ИмяКнопки);
	Элементы.Удалить(Элемент);
	
КонецПроцедуры



&НаКлиенте
Процедура ПоказатьСообщениеПользователю(Поле, Данные, ТекстОшибки)
	
	Сообщение = Новый СообщениеПользователю;
	Сообщение.Текст = ТекстОшибки;
	Сообщение.Поле = Поле;
	Сообщение.УстановитьДанные(Данные);
	Сообщение.Сообщить();

КонецПроцедуры



&НаКлиенте
Процедура ЗаполнитьСписокВыбораИсполнителейПроекта()
	
	Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля()), "Сформировать список выбора исполнителей", Истина) Тогда
		Возврат;
	КонецЕсли;
	Если Не ВсеРеквизитыЗаполнены(Новый Структура("Проект"), "Сформировать список выбора исполнителей", Истина, ЭтаФорма) Тогда
		Возврат;
	КонецЕсли;

	мИсполнителейПроекта = ПолучитьСписокИсполнителейПроектаИзТрекера();
	
	Элементы.Исполнитель.СписокВыбора.Очистить();
	Элементы.Исполнитель.СписокВыбора.Добавить("<>");
	Для Каждого Структура Из мИсполнителейПроекта Цикл
		Элементы.Исполнитель.СписокВыбора.Добавить(Структура.user.name);
	КонецЦикла;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьТаблицуНастраиваемыхПолей()
	
	Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля()), "Сформировать список выбора исполнителей", Истина) Тогда
		Возврат;
	КонецЕсли;

	мНастраиваемыхПолей = ПолучитьСписокНастраиваемыхПолейИзТрекера();
	
	тНастраиваемыеПоля.Очистить();
	Для Каждого Поле Из мНастраиваемыхПолей Цикл
		Если Поле.customized_type = "issue" И Поле.Свойство("is_filter") И Поле.is_filter Тогда
			нСтрока = тНастраиваемыеПоля.Добавить();
			
			нСтрока.Идентификатор = Поле.id;
			нСтрока.Имя = Поле.name;
			
			Если Поле.field_format = "string" Тогда
				нСтрока.Значение = "";
			ИначеЕсли Поле.field_format = "bool" Тогда
				Если Поле.Свойство("default_value") Тогда
					нСтрока.Значение = Поле.default_value;
				Иначе
					нСтрока.Значение = 0;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
	КонецЦикла;
	
 КонецПроцедуры
 
 &НаКлиенте
Процедура ЗаполнитьСписокВыбораПравДоступа()
	
	//Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля() + ", Проект"), "Сформировать список выбора прав доступа",, ЭтаФорма) Тогда
	//	Возврат;
	//КонецЕсли;

	//мПроект = ПолучитьИдентификаторПараметра(Проект, "projects");
	//
	////: ЗагруженныеДанные = Новый Соответствие
	//Данные = ЗагруженныеДанные.Получить("projects/"+мПроект+"/memberships");
	//
	//Если Данные = Неопределено Тогда
	//	Данные = ПолучитьДанныеРесурсаИзТрекера("projects/"+мПроект+"/memberships");
	//	
	//	Если ОтчетОВыполнении.ЕстьОшибки Тогда
	//		Сообщить(ОтчетОВыполнении.ТекстОшибки);
	//		Возврат;
	//	КонецЕсли;
	//	
	//	ЗагруженныеДанные.Вставить("projects/"+мПроект+"/memberships", Данные);
	//КонецЕсли;
	//
	//СписокПрав = Новый СписокЗначений;
	//СписокПрав.Добавить(0, "<>");
	//Для Каждого Структура Из Данные["memberships"] Цикл
	//	Для Каждого Право Из  Структура["roles"] Цикл
	//		Если СписокПрав.НайтиПоЗначению(Право.id) =Неопределено Тогда
	//			СписокПрав.Добавить(Право.name);
	//		КонецЕсли;
	//	КонецЦикла;
	//КонецЦикла;
	//
	//ЭлементыФормы.ПравоДоступа.СписокВыбора = СписокПрав;
	
КонецПроцедуры

&НаКлиенте
Процедура ЗаполнитьСписокВыбораПолеСсылкаНаОбъект1С()
	
	Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля()), "Сформировать список выбора исполнителей", Истина) Тогда
		Возврат;
	КонецЕсли;

	мНастраиваемыхПолей = ПолучитьСписокНастраиваемыхПолейИзТрекера();
	
	Для Каждого Поле Из мНастраиваемыхПолей Цикл
		Если Поле.customized_type = "issue" Тогда
			Элементы.ПолеСсылкаНаОбъект1С.СписокВыбора.Добавить(Поле["name"]);	
		КонецЕсли;
	КонецЦикла;
	
КонецПроцедуры


&НаКлиенте
// Заполнение списков выбора полей
//
Процедура ЗаполнитьСписокВыбораЭлементаФормы(ИмяПоля, ДопМассив=Неопределено) Экспорт
	Ключ = "";
	
	Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля()), "Сформировать список выбора исполнителей", Истина) Тогда
		Возврат;
	КонецЕсли;
	
	Если ИмяПоля = "Статус" Тогда
		Ресурс = "issue_statuses";
		
	ИначеЕсли ИмяПоля = "Приоритет" Тогда
		Ключ = "issue_priorities";
		Ресурс = "enumerations/issue_priorities";
		
	ИначеЕсли ИмяПоля = "Трекер" Тогда
		Ресурс = "trackers";
		
	ИначеЕсли ИмяПоля = "Деятельность" Тогда
		Ресурс = "enumerations/time_entry_activities";
		Ключ = "time_entry_activities";
		
	КонецЕсли;
	
	Если Ключ = "" Тогда
		Ключ = Ресурс;
	КонецЕсли;
	
	Данные = ПолучитьДанныеРесурсаПоКлючуИзТрекера(Ключ, Ресурс);
	
	Элементы[ИмяПоля].СписокВыбора.Очистить();
	Если ДопМассив <> Неопределено Тогда
		Для Каждого Эл Из ДопМассив Цикл
			Элементы[ИмяПоля].СписокВыбора.Добавить(Эл);
		КонецЦикла;
	КонецЕсли;
	
	Для Каждого Вариант Из Данные Цикл
		 Элементы[ИмяПоля].СписокВыбора.Добавить(Вариант.name);
	КонецЦикла;
	
КонецПроцедуры

&НаСервере
Функция ПолучитьДанныеРесурсаПоКлючуИзТрекера(Ключ, Ресурс)
	
	//: ЗагруженныеДанные = Новый Соответствие
	Данные = Объект.ЗагруженныеДанные.Получить(Ресурс);
	Если Данные = Неопределено Тогда
		Данные = ОбъектЭтойОбработки().ПолучитьДанныеРесурсаИзТрекера(Ресурс,,,, Ключ);
		
		ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
		
		Если ОбъектЭтойОбработки().ОтчетОВыполнении.ЕстьОшибки Тогда
			Возврат Новый Массив;
		КонецЕсли;
	КонецЕсли;
	
	Возврат Данные[Ключ];
	
КонецФункции


////////////////////////////////////////////////////////////////////////////////
// ПОВТОРЯЮЩИЕСЯ ДЕЙСТВИЯ ПРИ ИЗМЕНЕНИИ РАЗНЫХ РЕКВИЗИТОВ

&НаКлиенте
Процедура УстановитьВидимость()
	
	Элементы.Пароль.Видимость			= Объект.БазоваяАутентификация;
	Элементы.Пользователь.Видимость		= Объект.БазоваяАутентификация;
	Элементы.APIkey.Видимость			= Не Объект.БазоваяАутентификация;
	Элементы.ДекорацияAPIKey.Видимость	= Не Объект.БазоваяАутентификация;
	
	Элементы.ГруппаНастройки.Видимость	= ПоказатьНастройки;
	Элементы.ПоказатьНастройки.Пометка	= ПоказатьНастройки;
	
	Элементы.ДополнительнаяПанель.Видимость			= ПоказатьДополнительнуюПанель;
	Элементы.ПоказатьДополнительнуюПанель.Пометка	= ПоказатьДополнительнуюПанель;
	Элементы.СписокЗадачОписание.Видимость			= Не ПоказатьДополнительнуюПанель;
	
	Элементы.СписокЗадачЗатраченоВремени.Видимость	= Объект.ПолучатьДанныеОЗатраченномВремениПоЗадачам;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьДоступность()
	
	Элементы.СписокЗадачДобавитьЗадачу.Доступность		= УспешнаяИнициализация;
	Элементы.Изменить.Доступность						= УспешнаяИнициализация;
	Элементы.СписокЗадачОбновитьСписокЗадач.Доступность	= УспешнаяИнициализация;
	
КонецПроцедуры

&НаКлиенте
Процедура УстановитьЗаголовок()
	Заголовок = Заголовок + " v" + ПолучитьВерсиюОбработки();	
КонецПроцедуры


////////////////////////////////////////////////////////////////////////////////
// ПРОЦЕДУРЫ - ОБРАБОТЧИКИ КНОПОК КОМАНДНЫХ ПАНЕЛЕЙ ФОРМЫ


&НаКлиенте
Процедура РазвернутьВсе(Команда)
	Для Каждого СтрокаДерева Из ДеревоПроектовЗадач.ПолучитьЭлементы() Цикл
		Элементы.ДеревоПроектовЗадач.Развернуть(СтрокаДерева.ПолучитьИдентификатор(), Истина);
	КонецЦикла;
КонецПроцедуры

&НаКлиенте
Процедура СвернутьВсе(Команда)
	Для Каждого СтрокаДерева Из ДеревоПроектовЗадач.ПолучитьЭлементы() Цикл
		Элементы.ДеревоПроектовЗадач.Свернуть(СтрокаДерева.ПолучитьИдентификатор());
	КонецЦикла;
КонецПроцедуры


&НаКлиенте
Процедура ИнициализацияПриСтартеПриИзменении(Элемент)
	Перем Параметр;
	
	Если НЕ Объект.ИнициализацияПриСтарте Тогда
		Возврат;
	КонецЕсли;
	
	Оповещение = Новый ОписаниеОповещения("ОбработатьВыборПользователя", ЭтаФорма, Параметр);
	ПоказатьВопрос(Оповещение, "Выполнить инициализацию параметров обработки из трекера?", РежимДиалогаВопрос.ДаНет);

КонецПроцедуры

&НаКлиенте
Процедура ПолучатьДанныеОЗатраченномВремениПоЗадачамПриИзменении(Элемент)
	УстановитьВидимость();
КонецПроцедуры
   

&НаКлиенте
Процедура ПоказатьНастройки(Команда)
	
	ПоказатьНастройки = Не ПоказатьНастройки;
	
	Элементы[Команда.Имя].Пометка = ПоказатьНастройки;
	
	УстановитьВидимость();
	
КонецПроцедуры

&НаКлиенте
Процедура ПоказатьДополнительнуюПанель(Команда)
	
	ПоказатьДополнительнуюПанель = Не ПоказатьДополнительнуюПанель;
	
	Элементы[Команда.Имя].Пометка = ПоказатьДополнительнуюПанель;
	
	УстановитьВидимость();
	
КонецПроцедуры


&НаКлиенте
Процедура ДобавитьЗадачу(Команда)
	Сообщить("Данная опция еще не реализована!");
КонецПроцедуры

&НаКлиенте
Процедура УстановитьФлажки(Команда)
	Для Каждого СтрокаСписка Из Объект.СписокЗадач Цикл
		СтрокаСписка.Пометка = Истина;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура СнятьФлажки(Команда)
	Для Каждого СтрокаСписка Из Объект.СписокЗадач Цикл
		СтрокаСписка.Пометка = Ложь;
	КонецЦикла;	
КонецПроцедуры

&НаКлиенте
Процедура Редактировать(Команда)
	Сообщить("Данная опция еще не реализована!");
КонецПроцедуры

&НаКлиенте
Процедура УдалитьЗадачу(Команда)
	Сообщить("Данная опция еще не реализована!");
КонецПроцедуры

&НаКлиенте
Процедура ОбновитьСписокЗадач(Команда)
	
	Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля())) Тогда
		Возврат;
	КонецЕсли;
	
	ВыполнитьДействияДляОбновленияДереваИСпискаЗадач();
	
	Если Объект.ОтчетоВыполнении.ЕстьОшибки Тогда
		ПоказатьСообщениеПользователю("Объект.СписокЗадач", Объект, Объект.ОтчетоВыполнении.ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	// Развернуть дерево задач
	РазвернутьВсе(Неопределено);

	// Установить фокус на задачу которая редактировалась 
	УстановитьФокус();
	
	//Инициализация();  // параметров для редактирования задач
	//ПерезаполнитьКнопкиВариантовРедактированияЗадач();
КонецПроцедуры

&НаСервере
Процедура ВыполнитьДействияДляОбновленияДереваИСпискаЗадач()
	
	ДанныеРесурса = ПолучитьСписокЗадачИзТрекера();
	
	Если ОбъектЭтойОбработки().ОтчетОВыполнении.ЕстьОшибки Тогда
		ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
		Возврат;
	КонецЕсли;
	
	Дерево = ДанныеФормыВЗначение(ДеревоПроектовЗадач, Тип("ДеревоЗначений"));
	
	// Заполняем дерево проектов/задач
	Дерево = ОбъектЭтойОбработки().ЗаполнитьДеревоПоДаннымРесурсаИзТрекера(ДанныеРесурса, Дерево, "issues", "ДеревоПроектовЗадач" , Истина);

	// Заполнить таблицу задач
	//ЗаполнитьСписокЗадач_(ДанныеРесурса);
	ОбъектЭтойОбработки().ЗаполнитьСписокЗадач(ДанныеРесурса);
	
	Если Объект.ПолучатьДанныеОЗатраченномВремениПоЗадачам Тогда
		Для Каждого СтрокаСписка Из ОбъектЭтойОбработки().СписокЗадач Цикл
			Время = ПолучитьДанныеОЗатраченномВремениПоЗадаче(Формат(СтрокаСписка.Идентификатор, "ЧГ=0"));
			Для Каждого Эл Из Время Цикл
				СтрокаСписка.ЗатраченоВремени=СтрокаСписка.ЗатраченоВремени+Эл["hours"];
			КонецЦикла;
		КонецЦикла;
	КонецЕсли;

	ЗначениеВДанныеФормы(Дерево, ДеревоПроектовЗадач);
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
	
КонецПроцедуры

&НаСервере
Функция ПолучитьСписокЗадачИзТрекера()
	
	Отборы = ОбъектЭтойОбработки().СформироватьПараметрыЗапросаПолученияДанныхСТрекера(ЭтаФорма, Истина);
	Отборы = Отборы + "&include=journals,changesets";
	ДанныеРесурса = ОбъектЭтойОбработки().ПолучитьДанныеРесурсаИзТрекера("issues", Отборы, Ложь);
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
	
	Возврат ДанныеРесурса;

КонецФункции

&НаКлиенте
Процедура ПроверкаСоединения(Команда)
	Перем Параметр;
	
	ОтчетОВыполнении = ВыполнитьПроверкуСоединенияИнициализациюНаСервере();
	
	Если ОтчетОВыполнении.ЕстьОшибки Тогда
		ПоказатьПредупреждение(, ОтчетОВыполнении.ТекстОшибки);
	Иначе
		Оповещение = Новый ОписаниеОповещения("ОбработатьВыборПользователя", ЭтаФорма, Параметр);
		ПоказатьВопрос(Оповещение, "Подключение к серверу выполнено успешно! 
								   |Выполнить инициализацию основных параметров обработки?", РежимДиалогаВопрос.ДаНет);
	КонецЕсли;
	
	УстановитьВидимость();
	
КонецПроцедуры

&НаКлиенте
Процедура НастройкаПериода(Команда)
	
	СтандартныйПериод = Новый СтандартныйПериод(ВариантСтандартногоПериода.ПроизвольныйПериод);
	
	Диалог = Новый ДиалогРедактированияСтандартногоПериода;
	Диалог.Период = СтандартныйПериод;
	
	Если Диалог.Редактировать() Тогда
		
		СтандартныйПериод = Диалог.Период;
		
		ДатаНач = СтандартныйПериод.ДатаНачала;
		ДатаКон = СтандартныйПериод.ДатаОкончания;

	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Процедура ОбработатьВыборПользователя(Результат, Параметр) Экспорт // "Выполнить инициализацию параметров обработки из трекера?"
	
	Если Результат = КодВозвратаДиалога.Да Тогда
		
		Если Не ВсеРеквизитыЗаполнены(Новый Структура(ОбязательныеПоля())) Тогда
			Возврат;
		КонецЕсли;
		
		ВыполнитьИнициализациюОсновныхПараметровОбработки();

		Если Объект.ОтчетОВыполнении.ЕстьОшибки Тогда
			ПоказатьПредупреждение(, Объект.ОтчетОВыполнении.ТекстОшибки);
		Иначе
			УспешнаяИнициализация = Истина;
			Если Не Объект.ИнициализацияПриСтарте Тогда
				Объект.ИнициализацияПриСтарте = Истина;	
			КонецЕсли;
		КонецЕсли;
	КонецЕсли;
	
	Если УспешнаяИнициализация Тогда
		ЗаполнитьСписокВыбораПроекта();
		ПерезаполнитьСписокЗапросов();
		ЗаполнитьТаблицуНастраиваемыхПолей();
	КонецЕсли;
	
	УстановитьОписаниеЗадачиHTML();
	
	УстановитьДоступность();

КонецПроцедуры

&НаКлиенте
Процедура ОставитьКомментарийКЗадаче(Команда)
	
	ТекущаяЗадача = Элементы.СписокЗадач.ТекущиеДанные;
	Если ТекущаяЗадача = Неопределено Тогда
		ПоказатьСообщениеПользователю("СписокЗадач", Объект, "Необходимо выбрать задачу в списке!");
		Возврат;
	КонецЕсли;
	
	Объект.ЗадачаНомер						= ТекущаяЗадача.Идентификатор;
	Объект.ЗадачаНомерРродительскойЗадачи	= ТекущаяЗадача.НомерРодителя;
	Объект.ЗадачаПримечание					= Примечание;
	
	Если НЕ ВсеРеквизитыЗаполнены(Новый Структура("ЗадачаНомер, ЗадачаПримечание"), Элементы[Команда.Имя].Заголовок) Тогда
		Возврат;
	КонецЕсли;
	
	ВыполнитьОбновлениеЗадачиВТрекере();
	
	Если Объект.ОтчетоВыполнении.ЕстьОшибки Тогда
		ПоказатьСообщениеПользователю("СписокЗадач", Объект, Объект.ОтчетОВыполнении.ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	Примечание = "";
	
КонецПроцедуры

&НаКлиенте
Процедура ДобавитьЗаписьОЗатраченомВремени(Команда)
	
	ТекущаяЗадача = Элементы.СписокЗадач.ТекущиеДанные;
	Если ТекущаяЗадача = Неопределено Тогда
		ПоказатьСообщениеПользователю("СписокЗадач", Объект, "Необходимо выбрать задачу в списке!");
		Возврат;
	КонецЕсли;
	
	Объект.ЗадачаНомер						= ТекущаяЗадача.Идентификатор;
	Объект.ЗадачаКомментарии				= Комментарий;
	Объект.ЗадачаДеятельность				= Деятельность;
	Объект.ЗадачаЗатраченноеВремя			= ЗатраченноеВремя;
	
	Если НЕ ВсеРеквизитыЗаполнены(Новый Структура("ЗадачаНомер, ЗадачаДеятельность, ЗадачаЗатраченноеВремя"), Элементы[Команда.Имя].Заголовок) Тогда
		Возврат;
	КонецЕсли;
	
	ВыполнитьОбновлениеДанныхОЗатраченномВремениПоЗадаче();
	
	Если Объект.ОтчетоВыполнении.ЕстьОшибки Тогда
		ПоказатьСообщениеПользователю("СписокЗадач", Объект, Объект.ОтчетОВыполнении.ТекстОшибки);
		Возврат;
	КонецЕсли;
	
	Комментарий = "";
	ЗатраченноеВремя = 0;
	
	//мТекПозицияВСписке = ТекущаяЗадача.Идентификатор;
	//КоманднаяПанельСписокЗадачОбновитьСписок(Неопределено);
	
КонецПроцедуры



&НаСервере
Процедура ВыполнитьОбновлениеДанныхОЗатраченномВремениПоЗадаче()
	
	ОбъектЭтойОбработки().ОбновитьДанныеОЗатраченномВремениПоЗадаче();
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");

КонецПроцедуры

&НаСервере
Процедура ВыполнитьОбновлениеЗадачиВТрекере()
	
	ОбъектЭтойОбработки().ОбновитьЗадачуВТрекере();
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
	
КонецПроцедуры


&НаСервере
Процедура ВыполнитьИнициализациюОсновныхПараметровОбработки()

	ОбъектЭтойОбработки().Инициализация(Истина, ?(Проект<>"", Проект, Неопределено));	

	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");

КонецПроцедуры


&НаСервере
Функция ВыполнитьПроверкуСоединенияИнициализациюНаСервере()
	
	Данные = ОбъектЭтойОбработки().ПолучитьДанныеРесурсаИзТрекера("projects");
	
	ОтчетОВыполнении = ОбъектЭтойОбработки().ОтчетОВыполнении;
	
	Если НЕ ОтчетОВыполнении.ЕстьОшибки Тогда
		
		Если Данные["projects"].Количество() = 0 Тогда
			ОтчетОВыполнении.ТекстОшибки = "Список проектов, полученный из трекера, пуст, добавьте проект или обратитесь к администратору для проверки прав доступа в системе Redmine для текущего пользователя.";
			ОтчетОВыполнении.ЕстьОшибки = Истина;
		КонецЕсли;
		ОбъектЭтойОбработки().Инициализация(Истина, ?(Проект<>"", Проект, Неопределено));
	КонецЕсли;
	
	Возврат ОтчетОВыполнении;
	
КонецФункции




#Область СлужебныеПроцедурыИФункции

&НаСервере
Функция ОбъектЭтойОбработки()

	Если ОбъектЭтойОбработки = Неопределено Тогда
		ОбъектЭтойОбработки = РеквизитФормыВЗначение("Объект");
	КонецЕсли;
	
	Возврат ОбъектЭтойОбработки;

КонецФункции

&Насервере
Функция ПолучитьВерсиюОбработки()
	Возврат ОбъектЭтойОбработки().Метаданные().Комментарий;
КонецФункции

&НаСервере
Функция ПолучитьСписокПроектовИзТрекера()
	
	СписокПроектов = ОбъектЭтойОбработки().ПолучитьСписокПроектовИзТрекера();
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
	
	Возврат СписокПроектов;
КонецФункции

&НаСервере
Функция ПолучитьСписокИсполнителейПроектаИзТрекера()
	
	мИсполнителейПроекта = ОбъектЭтойОбработки().ПолучитьСписокИсполнителейПроектаИзТрекера(Проект);
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
	
	Возврат мИсполнителейПроекта;
КонецФункции

&НаСервере
Функция ПолучитьСписокНастраиваемыхПолейИзТрекера()
	мНастраиваемыхПолей = ОбъектЭтойОбработки().ПолучитьСписокНастраиваемыхПолейИзТрекера();
	
	ЗначениеВРеквизитФормы(ОбъектЭтойОбработки(), "Объект");
	
	Возврат мНастраиваемыхПолей;
КонецФункции



&НаСервере
Процедура ДобавитьКнопкуПерезапуска()
	НоваяКоманда = ЭтаФорма.Команды.Добавить("кфПерезапуск");
    НоваяКоманда.Действие= "кфПерезапустить";
    НовыйЭлемент = Элементы.Добавить("кфПерезапустить", Тип("КнопкаФормы"),Элементы.ФормаКоманднаяПанель);
    НовыйЭлемент.ИмяКоманды = "кфПерезапуск";
	НовыйЭлемент.Картинка = БиблиотекаКартинок.Перечитать;
	НовыйЭлемент.Отображение = ОтображениеКнопки.КартинкаИТекст;
    НовыйЭлемент.Заголовок = "Перезапустить ["+ТекущаяУниверсальнаяДата()+"]";
КонецПроцедуры

&НаКлиенте
Процедура кфПерезапустить(Команда)
    
    СтруктураПереоткрыть = Новый Структура();
    ПереоткрытьНаСервере("Поместить", СтруктураПереоткрыть);
    Если СтруктураПереоткрыть.ФункцияПомещения = "НачатьПомещениеФайла" Тогда
        НачатьПомещениеФайла(,,СтруктураПереоткрыть.ИспользуемоеИмяФайла,Ложь,);
    Иначе
        ПоместитьФайл(,СтруктураПереоткрыть.ИспользуемоеИмяФайла,,Ложь,);
    КонецЕсли;
	
	ЭтаФорма.Закрыть();
	ПереоткрытьНаСервере("Создать", СтруктураПереоткрыть);
    ОткрытьФорму(СтруктураПереоткрыть.ПолныйПутьИмениФормы);
    
КонецПроцедуры

&НаСервере
Процедура ПереоткрытьНаСервере(Режим, СтруктураПереоткрыть)
    
    Если Режим = "Поместить" Тогда
        СтруктураПереоткрыть.Очистить();
        СтруктураПереоткрыть.Вставить("ФункцияПомещения", ?(СокрЛП(Метаданные.РежимИспользованияМодальности) = "НеИспользовать", "НачатьПомещениеФайла", "ПоместитьФайл"));
        СтруктураПереоткрыть.Вставить("ИспользуемоеИмяФайла", СокрЛП(РеквизитформыВЗначение("Объект").ИспользуемоеИмяФайла));
        СтруктураПереоткрыть.Вставить("ПолныйПутьИмениФормы", СокрЛП(ЭтаФорма.ИмяФормы));
    ИначеЕсли Режим = "Создать" Тогда
        ВнешниеОбработки.Создать(СтруктураПереоткрыть.ИспользуемоеИмяФайла, Ложь);
    КонецЕсли;
    
КонецПроцедуры

&НаКлиенте
Процедура ПерейтиВТрекерПоКоманде(Команда)
	СтрокаПорт = ?(Объект.Порт = 80, "", ":" + Формат(Объект.Порт, "ЧГ=0"));
	
	Если Найти(Команда.Имя, "СписокЗадач") Тогда
		ИдПроекта = ПолучитьИдентификаторПараметра(Проект, "projects");
		ЗапуститьПриложение("http://" + Объект.Сервер + СтрокаПорт + "/projects/p"+Формат(ИдПроекта-1, "ЧЦ=3; ЧВН=; ЧГ=0") + "/issues");
	Иначе
		ТекСтрока = Элементы.СписокЗадач.ТекущиеДанные;
		Если Не ТекСтрока = Неопределено Тогда
			ЗапуститьПриложение("http://" + Объект.Сервер + СтрокаПорт + "/issues/"+Формат(ТекСтрока.Идентификатор, "ЧГ=0"));
		КонецЕсли;
	КонецЕсли;
КонецПроцедуры

&НаКлиенте
Функция ВернутьПервогоРодителяСтроки(СтрокаДерева)
	
	Если СтрокаДерева.Родитель = Неопределено Тогда
		Возврат СтрокаДерева;
	Иначе
		Возврат ВернутьПервогоРодителяСтроки(СтрокаДерева.Родитель);
	КонецЕсли;
	
КонецФункции



#КонецОбласти 

УспешнаяИнициализация = Ложь;

