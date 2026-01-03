import { useState } from "react";
import { useQuery, useMutation } from "@tanstack/react-query";
import { queryClient, apiRequest } from "@/lib/queryClient";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { insertMessageSchema, type Message, type InsertMessage } from "@shared/schema";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { Badge } from "@/components/ui/badge";
import { Skeleton } from "@/components/ui/skeleton";
import { useToast } from "@/hooks/use-toast";
import { ThemeToggle } from "@/components/theme-toggle";
import {
  Form,
  FormControl,
  FormField,
  FormItem,
  FormLabel,
  FormMessage,
} from "@/components/ui/form";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog";
import { MessageSquare, Edit, Trash2, Send, CheckCircle2, XCircle } from "lucide-react";
import { formatDistanceToNow } from "date-fns";

export default function Home() {
  const { toast } = useToast();
  const [editingMessage, setEditingMessage] = useState<Message | null>(null);
  const [deleteMessageId, setDeleteMessageId] = useState<number | null>(null);

  const { data: messages = [], isLoading } = useQuery<Message[]>({
    queryKey: ["/api/messages"],
  });

  const { data: health } = useQuery<{ status: string; timestamp: string }>({
    queryKey: ["/api/health"],
    refetchInterval: 5000,
  });

  const createForm = useForm<InsertMessage>({
    resolver: zodResolver(insertMessageSchema),
    defaultValues: {
      name: "",
      content: "",
    },
  });

  const editForm = useForm<InsertMessage>({
    resolver: zodResolver(insertMessageSchema),
    defaultValues: {
      name: "",
      content: "",
    },
  });

  const createMutation = useMutation({
    mutationFn: async (data: InsertMessage) => {
      return await apiRequest("POST", "/api/messages", data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/messages"] });
      createForm.reset();
      toast({
        title: "Success",
        description: "Message created successfully",
      });
    },
    onError: (error: Error) => {
      toast({
        variant: "destructive",
        title: "Error",
        description: error.message || "Failed to create message",
      });
    },
  });

  const updateMutation = useMutation({
    mutationFn: async ({ id, data }: { id: number; data: InsertMessage }) => {
      return await apiRequest("PUT", `/api/messages/${id}`, data);
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/messages"] });
      setEditingMessage(null);
      editForm.reset();
      toast({
        title: "Success",
        description: "Message updated successfully",
      });
    },
    onError: (error: Error) => {
      toast({
        variant: "destructive",
        title: "Error",
        description: error.message || "Failed to update message",
      });
    },
  });

  const deleteMutation = useMutation({
    mutationFn: async (id: number) => {
      return await apiRequest("DELETE", `/api/messages/${id}`, {});
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["/api/messages"] });
      setDeleteMessageId(null);
      toast({
        title: "Success",
        description: "Message deleted successfully",
      });
    },
    onError: (error: Error) => {
      toast({
        variant: "destructive",
        title: "Error",
        description: error.message || "Failed to delete message",
      });
    },
  });

  const onCreateSubmit = (data: InsertMessage) => {
    createMutation.mutate(data);
  };

  const onEditSubmit = (data: InsertMessage) => {
    if (editingMessage) {
      updateMutation.mutate({ id: editingMessage.id, data });
    }
  };

  const startEdit = (message: Message) => {
    setEditingMessage(message);
    editForm.reset({
      name: message.name,
      content: message.content,
    });
  };

  const cancelEdit = () => {
    setEditingMessage(null);
    editForm.reset();
  };

  return (
    <div className="min-h-screen bg-background">
      <header className="sticky top-0 z-50 border-b bg-card/95 backdrop-blur supports-[backdrop-filter]:bg-card/60">
        <div className="max-w-4xl mx-auto px-4 py-4 flex items-center justify-between">
          <div className="flex items-center gap-3">
            <MessageSquare className="w-8 h-8 text-primary" />
            <h1 className="text-3xl font-bold" data-testid="text-app-title">Message Manager</h1>
          </div>
          <div className="flex items-center gap-2">
            {health?.status === "ok" ? (
              <Badge variant="outline" className="gap-2" data-testid="badge-health-status">
                <CheckCircle2 className="w-3 h-3 text-status-online" />
                <span className="text-sm font-medium">Backend: Healthy</span>
              </Badge>
            ) : (
              <Badge variant="outline" className="gap-2" data-testid="badge-health-status">
                <XCircle className="w-3 h-3 text-status-busy" />
                <span className="text-sm font-medium">Backend: Offline</span>
              </Badge>
            )}
            <ThemeToggle />
          </div>
        </div>
      </header>

      <main className="max-w-4xl mx-auto px-4 py-8">
        <div className="space-y-8">
          <Card data-testid="card-message-form">
            <CardHeader>
              <CardTitle className="text-xl font-semibold">Submit New Message</CardTitle>
            </CardHeader>
            <CardContent>
              <Form {...createForm}>
                <form onSubmit={createForm.handleSubmit(onCreateSubmit)} className="space-y-4">
                  <FormField
                    control={createForm.control}
                    name="name"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Your Name</FormLabel>
                        <FormControl>
                          <Input
                            placeholder="Your name"
                            {...field}
                            data-testid="input-name"
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={createForm.control}
                    name="content"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Message</FormLabel>
                        <FormControl>
                          <Textarea
                            placeholder="Your message..."
                            rows={4}
                            {...field}
                            data-testid="input-content"
                          />
                        </FormControl>
                        <FormMessage />
                      </FormItem>
                    )}
                  />
                  <div className="flex justify-end">
                    <Button
                      type="submit"
                      disabled={createMutation.isPending}
                      className="gap-2"
                      data-testid="button-submit"
                    >
                      <Send className="w-4 h-4" />
                      {createMutation.isPending ? "Sending..." : "Send Message"}
                    </Button>
                  </div>
                </form>
              </Form>
            </CardContent>
          </Card>

          <div>
            <div className="flex items-center justify-between mb-6">
              <h2 className="text-xl font-semibold" data-testid="text-messages-title">All Messages</h2>
              <Badge variant="secondary" data-testid="badge-message-count">
                {messages.length} {messages.length === 1 ? "message" : "messages"}
              </Badge>
            </div>

            {isLoading ? (
              <div className="space-y-4">
                {[1, 2, 3].map((i) => (
                  <Card key={i}>
                    <CardContent className="p-6 space-y-3">
                      <Skeleton className="h-5 w-32" />
                      <Skeleton className="h-4 w-full" />
                      <Skeleton className="h-4 w-3/4" />
                      <Skeleton className="h-4 w-24" />
                    </CardContent>
                  </Card>
                ))}
              </div>
            ) : messages.length === 0 ? (
              <Card>
                <CardContent className="p-12 text-center">
                  <MessageSquare className="w-16 h-16 mx-auto mb-4 text-muted-foreground" />
                  <h3 className="text-lg font-semibold mb-2" data-testid="text-empty-state">
                    No messages yet
                  </h3>
                  <p className="text-muted-foreground">
                    Be the first to post a message!
                  </p>
                </CardContent>
              </Card>
            ) : (
              <div className="space-y-4">
                {messages.map((message) => (
                  <Card key={message.id} data-testid={`card-message-${message.id}`}>
                    <CardContent className="p-6">
                      <div className="space-y-3">
                        <div className="flex items-start justify-between gap-4">
                          <div className="flex-1 space-y-2">
                            <h3 className="font-bold text-base" data-testid={`text-message-name-${message.id}`}>
                              {message.name}
                            </h3>
                            <p className="text-base whitespace-pre-wrap" data-testid={`text-message-content-${message.id}`}>
                              {message.content}
                            </p>
                            <p className="text-xs text-muted-foreground" data-testid={`text-message-time-${message.id}`}>
                              {formatDistanceToNow(new Date(message.createdAt), {
                                addSuffix: true,
                              })}
                            </p>
                          </div>
                        </div>
                        <div className="flex justify-end gap-2 pt-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => startEdit(message)}
                            className="gap-2"
                            data-testid={`button-edit-${message.id}`}
                          >
                            <Edit className="w-3 h-3" />
                            Edit
                          </Button>
                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => setDeleteMessageId(message.id)}
                            className="gap-2"
                            data-testid={`button-delete-${message.id}`}
                          >
                            <Trash2 className="w-3 h-3" />
                            Delete
                          </Button>
                        </div>
                      </div>
                    </CardContent>
                  </Card>
                ))}
              </div>
            )}
          </div>
        </div>
      </main>

      <Dialog open={editingMessage !== null} onOpenChange={(open) => !open && cancelEdit()}>
        <DialogContent data-testid="dialog-edit-message">
          <DialogHeader>
            <DialogTitle>Edit Message</DialogTitle>
            <DialogDescription>
              Make changes to your message below.
            </DialogDescription>
          </DialogHeader>
          <Form {...editForm}>
            <form onSubmit={editForm.handleSubmit(onEditSubmit)} className="space-y-4">
              <FormField
                control={editForm.control}
                name="name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Your Name</FormLabel>
                    <FormControl>
                      <Input
                        placeholder="Your name"
                        {...field}
                        data-testid="input-edit-name"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <FormField
                control={editForm.control}
                name="content"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Message</FormLabel>
                    <FormControl>
                      <Textarea
                        placeholder="Your message..."
                        rows={4}
                        {...field}
                        data-testid="input-edit-content"
                      />
                    </FormControl>
                    <FormMessage />
                  </FormItem>
                )}
              />
              <div className="flex justify-end gap-2">
                <Button
                  type="button"
                  variant="outline"
                  onClick={cancelEdit}
                  data-testid="button-cancel-edit"
                >
                  Cancel
                </Button>
                <Button
                  type="submit"
                  disabled={updateMutation.isPending}
                  data-testid="button-save-edit"
                >
                  {updateMutation.isPending ? "Saving..." : "Save Changes"}
                </Button>
              </div>
            </form>
          </Form>
        </DialogContent>
      </Dialog>

      <AlertDialog open={deleteMessageId !== null} onOpenChange={() => setDeleteMessageId(null)}>
        <AlertDialogContent data-testid="dialog-delete-confirm">
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Message</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete this message? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel data-testid="button-cancel-delete">Cancel</AlertDialogCancel>
            <AlertDialogAction
              onClick={() => {
                if (deleteMessageId) {
                  deleteMutation.mutate(deleteMessageId);
                }
              }}
              className="bg-destructive text-destructive-foreground hover:bg-destructive/90"
              data-testid="button-confirm-delete"
            >
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </div>
  );
}
