import React from 'react';
import { ViewStyle } from 'react-native';

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
 */
declare const ScribeUpWidget: React.ForwardRefExoticComponent<
    ScribeupWidgetViewProps & React.RefAttributes<ScribeupWidgetViewRef>
>;

export default ScribeUpWidget;