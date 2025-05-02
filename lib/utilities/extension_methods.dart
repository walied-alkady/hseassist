
extension StringExtension on String {
    String capitalizeFirstLetter() {
        if (isEmpty) return this;
        return this[0].toUpperCase() + this.substring(1).toLowerCase();
    }
}
