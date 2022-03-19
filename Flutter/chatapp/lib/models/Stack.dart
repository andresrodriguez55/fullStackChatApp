import 'dart:collection';

class Stack<T> 
{
  final queue = Queue<T>();

  void push(T element) 
  {
    queue.addLast(element);
  }

  T? pop() 
  {
    return (this.isEmpty) ? null : queue.removeLast();
  }

  void clear() 
  {
    queue.clear();
  }

  bool get isEmpty => queue.isEmpty;
  bool get isNotEmpty => queue.isNotEmpty;
  int get length => this.queue.length;
}