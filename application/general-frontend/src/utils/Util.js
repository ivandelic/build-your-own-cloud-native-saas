var Binding = {};
var ArrayUtil = {};

ArrayUtil.contains = function (array, obj) {
	var i = array.length;
	while (i--) {
		if (array[i] === obj) {
			return true;
		}
	}
	return false;
}

Binding.updateByString = function(o, path, value) {
	console.log(o);
    console.log(path);
    console.log(value);
	path = path.replace(/\[(\w+)\]/g, '.$1');
	path = path.replace(/^\./, '');
	var leaf = o;
	var nodes = path.split('.');
	for (var i = 0; i < nodes.length - 1; ++i) {
		var node = nodes[i];
		if (!(node in leaf) || !leaf[node]) {
			leaf[node] = {};
		}
		leaf = leaf[node];
	}
	leaf[nodes[nodes.length - 1]] = value;
	return o;
}

Binding.findByString = function(obj, path) {
	path = path.replace(/\[(\w+)\]/g, '.$1');
	path = path.replace(/^\./, '');
	var nodes = path.split('.');
	for (var i = 0; i < nodes.length; ++i) {
		var node = nodes[i];

		if (!!obj && node in obj) {
			obj = obj[node];
		} else {
			return;
		}
	}
	return obj;
}

export { Binding, ArrayUtil }