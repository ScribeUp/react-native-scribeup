import React, { useRef, useImperativeHandle, forwardRef } from 'react';
import { ViewStyle, UIManager, findNodeHandle, Platform } from 'react-native';
import { requireNativeComponent } from 'react-native';

const LINKING_ERROR =
  `The package 'scribeup-react-native-scribeup' doesn't seem to be linked. Make sure: \n\n` +
  Platform.select({
    ios: "- You have run 'pod install'\n",
    default: "",
  }) +
  "- You rebuilt the app after installing the package\n";

const ComponentName = 'ScribeupWidgetView';

const ScribeupWidgetViewNative =
  UIManager.getViewManagerConfig(ComponentName) != null
    ? requireNativeComponent<ScribeupWidgetViewProps>(ComponentName)
    : () => {
        throw new Error(LINKING_ERROR);
      };

export interface ScribeupWidgetViewProps {
  /**
   * The URL to load in the widget
   */
  url: string;
  
  /**
   * Optional style for the widget container
   */
  style?: ViewStyle;
}

export interface ScribeupWidgetViewRef {
  /**
   * Reload the current page in the widget
   */
  reload: () => void;
  
  /**
   * Load a new URL in the widget
   * @param url The new URL to load
   */
  loadURL: (url: string) => void;
}

/**
 * ScribeUp Widget Component
 * 
 * A lightweight widget view that displays a webview for subscription management.
 * This is a flexible alternative to the full-screen ScribeUp component that can be
 * embedded anywhere in your app and sized however you want.
 * 
 * Unlike the full ScribeUp component, this widget:
 * - Takes only one required parameter: url
 * - Has no header or navigation controls
 * - Is a simple View that can be sized flexibly
 * - Is focused purely on displaying web content
 * 
 * @example
 * ```tsx
 * import { ScribeUpWidget } from 'scribeup-react-native-scribeup';
 * 
 * const MyComponent = () => {
 *   const widgetRef = useRef<ScribeupWidgetViewRef>(null);
 * 
 *   const handleReload = () => {
 *     widgetRef.current?.reload();
 *   };
 * 
 * 
 *   return (
 *     <ScribeUpWidget
 *       ref={widgetRef}
 *       url="https://your-subscription-url.com"
 *       style={{ width: '100%', height: 400 }}
 *     />
 *   );
 * };
 * ```
 */
const ScribeUpWidget = forwardRef<ScribeupWidgetViewRef, ScribeupWidgetViewProps>(
  ({ url, style }, ref) => {
    const nativeRef = useRef(null);

    useImperativeHandle(ref, () => ({
      reload: () => {
        const viewId = findNodeHandle(nativeRef.current);
        if (viewId) {
          if (Platform.OS === 'ios') {
            UIManager.dispatchViewManagerCommand(viewId, 'reload', []);
          } else {
            UIManager.dispatchViewManagerCommand(viewId, UIManager.getViewManagerConfig(ComponentName).Commands.reload, []);
          }
        }
      },
      loadURL: (newUrl: string) => {
        const viewId = findNodeHandle(nativeRef.current);
        if (viewId) {
          if (Platform.OS === 'ios') {
            UIManager.dispatchViewManagerCommand(viewId, 'loadURL', [newUrl]);
          } else {
            UIManager.dispatchViewManagerCommand(viewId, UIManager.getViewManagerConfig(ComponentName).Commands.loadURL, [newUrl]);
          }
        }
      },
    }));

    return (
      <ScribeupWidgetViewNative
        ref={nativeRef}
        url={url}
        style={style}
      />
    );
  }
);

ScribeUpWidget.displayName = 'ScribeUpWidget';

export default ScribeUpWidget;