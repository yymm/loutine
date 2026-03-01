// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'link.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Link {

 int get id; String get title; String get url;@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) DateTime get createdAt;@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) DateTime get updatedAt;@JsonKey(name: 'tag_ids') List<int> get tagIds;
/// Create a copy of Link
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LinkCopyWith<Link> get copyWith => _$LinkCopyWithImpl<Link>(this as Link, _$identity);

  /// Serializes this Link to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Link&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other.tagIds, tagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,createdAt,updatedAt,const DeepCollectionEquality().hash(tagIds));

@override
String toString() {
  return 'Link(id: $id, title: $title, url: $url, createdAt: $createdAt, updatedAt: $updatedAt, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class $LinkCopyWith<$Res>  {
  factory $LinkCopyWith(Link value, $Res Function(Link) _then) = _$LinkCopyWithImpl;
@useResult
$Res call({
 int id, String title, String url,@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) DateTime createdAt,@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) DateTime updatedAt,@JsonKey(name: 'tag_ids') List<int> tagIds
});




}
/// @nodoc
class _$LinkCopyWithImpl<$Res>
    implements $LinkCopyWith<$Res> {
  _$LinkCopyWithImpl(this._self, this._then);

  final Link _self;
  final $Res Function(Link) _then;

/// Create a copy of Link
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? url = null,Object? createdAt = null,Object? updatedAt = null,Object? tagIds = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tagIds: null == tagIds ? _self.tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [Link].
extension LinkPatterns on Link {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Link value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Link() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Link value)  $default,){
final _that = this;
switch (_that) {
case _Link():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Link value)?  $default,){
final _that = this;
switch (_that) {
case _Link() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String title,  String url, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)  DateTime createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)  DateTime updatedAt, @JsonKey(name: 'tag_ids')  List<int> tagIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Link() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.createdAt,_that.updatedAt,_that.tagIds);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String title,  String url, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)  DateTime createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)  DateTime updatedAt, @JsonKey(name: 'tag_ids')  List<int> tagIds)  $default,) {final _that = this;
switch (_that) {
case _Link():
return $default(_that.id,_that.title,_that.url,_that.createdAt,_that.updatedAt,_that.tagIds);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String title,  String url, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson)  DateTime createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson)  DateTime updatedAt, @JsonKey(name: 'tag_ids')  List<int> tagIds)?  $default,) {final _that = this;
switch (_that) {
case _Link() when $default != null:
return $default(_that.id,_that.title,_that.url,_that.createdAt,_that.updatedAt,_that.tagIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Link implements Link {
  const _Link({required this.id, required this.title, required this.url, @JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) required this.createdAt, @JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) required this.updatedAt, @JsonKey(name: 'tag_ids') final  List<int> tagIds = const []}): _tagIds = tagIds;
  factory _Link.fromJson(Map<String, dynamic> json) => _$LinkFromJson(json);

@override final  int id;
@override final  String title;
@override final  String url;
@override@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) final  DateTime createdAt;
@override@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) final  DateTime updatedAt;
 final  List<int> _tagIds;
@override@JsonKey(name: 'tag_ids') List<int> get tagIds {
  if (_tagIds is EqualUnmodifiableListView) return _tagIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tagIds);
}


/// Create a copy of Link
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LinkCopyWith<_Link> get copyWith => __$LinkCopyWithImpl<_Link>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LinkToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Link&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.url, url) || other.url == url)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&const DeepCollectionEquality().equals(other._tagIds, _tagIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,url,createdAt,updatedAt,const DeepCollectionEquality().hash(_tagIds));

@override
String toString() {
  return 'Link(id: $id, title: $title, url: $url, createdAt: $createdAt, updatedAt: $updatedAt, tagIds: $tagIds)';
}


}

/// @nodoc
abstract mixin class _$LinkCopyWith<$Res> implements $LinkCopyWith<$Res> {
  factory _$LinkCopyWith(_Link value, $Res Function(_Link) _then) = __$LinkCopyWithImpl;
@override @useResult
$Res call({
 int id, String title, String url,@JsonKey(name: 'created_at', fromJson: _dateTimeFromJson) DateTime createdAt,@JsonKey(name: 'updated_at', fromJson: _dateTimeFromJson) DateTime updatedAt,@JsonKey(name: 'tag_ids') List<int> tagIds
});




}
/// @nodoc
class __$LinkCopyWithImpl<$Res>
    implements _$LinkCopyWith<$Res> {
  __$LinkCopyWithImpl(this._self, this._then);

  final _Link _self;
  final $Res Function(_Link) _then;

/// Create a copy of Link
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? url = null,Object? createdAt = null,Object? updatedAt = null,Object? tagIds = null,}) {
  return _then(_Link(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tagIds: null == tagIds ? _self._tagIds : tagIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}

// dart format on
