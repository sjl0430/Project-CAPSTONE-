import 'dart:async';

// StreamControllerReemit 클래스: 스트림의 최신 값을 캐싱하고, 스트림이 리슨될 때마다 최신 값을 다시 방출하는 스트림 컨트롤러입니다.
class StreamControllerReemit<T> {
  T? _latestValue; // 스트림의 최신 값을 저장하는 변수입니다.

  final StreamController<T> _controller = StreamController<T>.broadcast(); // 브로드캐스트 스트림 컨트롤러를 생성합니다.

  // 생성자: 초기 값을 설정할 수 있습니다.
  StreamControllerReemit({T? initialValue}) : _latestValue = initialValue;

  // 스트림을 반환합니다. 스트림이 리슨될 때 최신 값을 즉시 방출합니다.
  Stream<T> get stream {
    return _latestValue != null
        ? _controller.stream.newStreamWithInitialValue(_latestValue!) // 초기 값을 포함하는 새 스트림을 생성합니다.
        : _controller.stream; // 초기 값이 없으면 기존 스트림을 반환합니다.
  }

  // 최신 값을 반환합니다.
  T? get value => _latestValue;

  // 새 값을 스트림에 추가하고 최신 값을 업데이트합니다.
  void add(T newValue) {
    _latestValue = newValue;
    _controller.add(newValue);
  }

  // 스트림 컨트롤러를 닫습니다.
  Future<void> close() {
    return _controller.close();
  }
}

// 스트림 확장: 초기 값을 즉시 방출하는 새 스트림을 생성하는 확장입니다.
extension _StreamNewStreamWithInitialValue<T> on Stream<T> {
  Stream<T> newStreamWithInitialValue(T initialValue) {
    return transform(_NewStreamWithInitialValueTransformer(initialValue)); // 스트림 변환기를 사용하여 새 스트림을 생성합니다.
  }
}

// _NewStreamWithInitialValueTransformer 클래스: 초기 값을 포함하는 새 스트림을 생성하는 스트림 변환기입니다.
class _NewStreamWithInitialValueTransformer<T> extends StreamTransformerBase<T, T> {
  final T initialValue; // 새 스트림에 푸시할 초기 값입니다.

  late StreamController<T> controller; // 새 스트림의 컨트롤러입니다.

  late StreamSubscription<T> subscription; // 원본 스트림의 구독입니다.

  var listenerCount = 0; // 새 스트림의 리스너 수를 저장합니다.

  _NewStreamWithInitialValueTransformer(this.initialValue);

  // 스트림을 변환하고 새 스트림을 반환합니다.
  @override
  Stream<T> bind(Stream<T> stream) {
    if (stream.isBroadcast) {
      return _bind(stream, broadcast: true); // 브로드캐스트 스트림인 경우 브로드캐스트 모드로 바인딩합니다.
    } else {
      return _bind(stream); // 싱글 구독 스트림인 경우 싱글 구독 모드로 바인딩합니다.
    }
  }

  // 스트림을 바인딩하는 내부 함수입니다.
  Stream<T> _bind(Stream<T> stream, {bool broadcast = false}) {
    // 원본 스트림의 구독 콜백입니다.

    // 원본 스트림에서 데이터가 방출될 때 새 스트림으로 전달합니다.
    void onData(T data) {
      controller.add(data);
    }

    // 원본 스트림이 완료되면 새 스트림을 닫습니다.
    void onDone() {
      controller.close();
    }

    // 원본 스트림에서 오류가 발생하면 새 스트림으로 전달합니다.
    void onError(Object error) {
      controller.addError(error);
    }

    // 클라이언트가 새 스트림을 리슨할 때 초기 값을 방출하고 필요한 경우 원본 스트림을 구독합니다.
    void onListen() {
      controller.add(initialValue); // 초기 값을 새 스트림에 방출합니다.

      if (listenerCount == 0) {
        subscription = stream.listen(
          onData,
          onError: onError,
          onDone: onDone,
        ); // 필요한 경우 원본 스트림을 구독합니다.
      }

      listenerCount++; // 새 스트림의 리스너 수를 증가시킵니다.
    }

    // 새 스트림 컨트롤러의 콜백입니다.

    // (싱글 구독 전용) 클라이언트가 새 스트림을 일시중지하면 원본 스트림을 일시중지합니다.
    void onPause() {
      subscription.pause();
    }

    // (싱글 구독 전용) 클라이언트가 새 스트림을 다시 시작하면 원본 스트림을 다시 시작합니다.
    void onResume() {
      subscription.resume();
    }

    // 클라이언트가 새 스트림의 구독을 취소할 때 호출됩니다.
    void onCancel() {
      listenerCount--; // 새 스트림의 리스너 수를 감소시킵니다.

      if (listenerCount == 0) {
        subscription.cancel();
        controller.close(); // 리스너가 더 이상 없으면 원본 스트림 구독을 취소하고 새 스트림 컨트롤러를 닫습니다.
      }
    }

    // 새 스트림을 반환합니다.

    // 새 스트림 컨트롤러를 생성합니다.
    if (broadcast) {
      controller = StreamController<T>.broadcast(
        onListen: onListen,
        onCancel: onCancel,
      );
    } else {
      controller = StreamController<T>(
        onListen: onListen,
        onPause: onPause,
        onResume: onResume,
        onCancel: onCancel,
      );
    }

    return controller.stream; // 새 스트림을 반환합니다.
  }
}