open Sdl
open Sdlevent
module Image = Sdlimage

let event_loop () =
  match Event.poll_event () with
  | None -> ()
  | Some Quit _ ->
    Sdl.quit();
    exit 0
  | _ -> ()


let load_sprite renderer filename =
  let rw = RWops.from_file ~filename ~mode:"rb" in
  let surf = Image.load_png_rw rw in
  let tex = Texture.create_from_surface renderer surf in
  Surface.free surf;
  (tex)
  

let main () =
  let width, height = (640, 480) in
  Sdl.init [`VIDEO];
  Sdlimage.init [`PNG];
  let window = Sdlwindow.create2
      ~x:`undefined ~y:`undefined
      ~width ~height
      ~title:"SDL2 tutorial"
      ~flags:[Window.Resizable]
  in
  let renderer =
    Render.create_renderer ~win:window ~index:(-1) ~flags:[Render.Accelerated]
  in
  let sprite = load_sprite renderer "resources/sprites/godot.png" in
  let render renderer =
    Render.clear renderer;
    Render.set_scale renderer (1.0, 1.0);
    Render.copy renderer ~texture:sprite
      ~src_rect:(Rect.make4 ~x:0 ~y:0 ~w:64 ~h:64)
      ~dst_rect:(Rect.make4 ~x:100 ~y:100 ~w:64 ~h:64)
      ();
    Render.render_present renderer;
  in
  let rec main_loop () =
    event_loop ();
    render renderer;
    main_loop ()
  in
  main_loop ()

let () = main ()
