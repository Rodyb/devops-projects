# Design Guidelines: Message Management Application

## Design Approach
**System**: Material Design with simplified implementation  
**Rationale**: This is a utility-focused CRUD application for QA/DevOps demonstration. Clean, professional aesthetics with emphasis on usability and clarity over visual flair.

## Typography
- **Primary Font**: Inter (Google Fonts)
- **Hierarchy**:
  - Page Title: text-3xl font-bold
  - Section Headers: text-xl font-semibold
  - Message Content: text-base font-normal
  - Labels/Metadata: text-sm font-medium
  - Timestamps: text-xs text-gray-500

## Layout System
**Spacing Units**: Tailwind primitives of 4, 6, and 8
- Component spacing: p-6, gap-4
- Section margins: my-8
- Card padding: p-6
- Form field gaps: gap-4

**Container Strategy**:
- Main container: max-w-4xl mx-auto px-4
- Single-column layout throughout
- Full-width cards with rounded corners (rounded-lg)

## Component Library

### Main Layout
- **Header**: Fixed top bar with app title "Message Manager" and health status indicator (green dot + "Online")
- **Content Area**: Single column, vertically stacked sections with consistent spacing

### Message Form Section
- **Card-based design** with subtle border and shadow (border shadow-sm)
- Section title: "Submit New Message"
- Form fields:
  - Text input for name (placeholder: "Your name")
  - Textarea for message (placeholder: "Your message...", rows: 4)
  - Submit button: Primary action, full-width on mobile, w-auto on desktop
- Validation: Display error states with red border and helper text below fields

### Message List Section
- **Section header**: "All Messages" with message count badge
- **Message Cards**: Each message in a card with:
  - Author name in bold
  - Message content with line breaks preserved
  - Timestamp (e.g., "2 minutes ago") in muted text
  - Action buttons row: Edit (icon + text) and Delete (icon + text) aligned right
  - Divider between cards or subtle gap-4 spacing

- **Empty State**: When no messages, centered illustration placeholder with text "No messages yet. Be the first to post!"

### Buttons
- **Primary**: Solid background, medium weight text, rounded corners (rounded-md), px-6 py-2.5
- **Secondary/Danger**: Outlined or ghost style for edit/delete actions
- **Icon Buttons**: Small circular buttons with icon only for compact actions

### Health Status
- **Top-right corner indicator**: Small pill-shaped badge showing "Backend: Healthy" with green dot
- Updates automatically, shows red on failure

## Navigation & Interaction
- **No traditional navigation** - single page application
- **Smooth transitions**: Messages appear/disappear with subtle fade
- **Loading states**: Skeleton cards while fetching messages
- **Action feedback**: Toast notifications for success/error (top-right, auto-dismiss in 3s)

## Responsive Behavior
- **Mobile (base)**: Stack everything vertically, full-width buttons, comfortable touch targets (min-height: 44px)
- **Desktop (md:)**: Wider containers, inline form buttons, more breathing room

## Images
**No images required** for this utility application. Focus on clean typography and structured layouts.

## Key Principles
1. **Clarity over complexity**: Every element serves a functional purpose
2. **Consistent spacing**: Use the defined spacing units religiously
3. **Professional restraint**: Minimal animations, focus on usability
4. **Accessibility-first**: High contrast, proper form labels, keyboard navigation support

This design creates a professional, demo-ready application that showcases functionality without visual distraction.