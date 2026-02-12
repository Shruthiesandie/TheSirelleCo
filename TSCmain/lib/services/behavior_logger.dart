import 'confusion_engine.dart';
import 'predictive_engine.dart';

class BehaviorLogger {
  static void log({
    required String userId,
    required String screenName,
    required String actionType,
    required String actionValue,
  }) {
    // For now we only print logs locally.
    // Backend API connection will be added later.
    print("LOG => $userId | $screenName | $actionType | $actionValue");

    // 🧠 Send event to Confusion Engine (AI Brain)
    ConfusionEngine.record(
      userId: userId,
      screen: screenName,
      type: actionType,
      value: actionValue,
    );

    // 🔮 Send event to Predictive Engine (AI Prediction Brain)
    PredictiveEngine.recordNavigation(
      userId: userId,
      screen: screenName,
      action: actionType,
    );
  }
}
