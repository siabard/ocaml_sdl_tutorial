open Sdl
open Sdlevent
module Image = Sdlimage

module SpriteMap = Map.Make(String)


type sprite_cell = {
    x: int;
    y: int;
    w: int;
    h: int;
  }

                
let event_loop () =
  match Event.poll_event () with
  | None -> ()
  | Some Quit _ ->
    Sdl.quit();
    exit 0
  | _ -> ()


let load_sprite renderer sprite_map id  filename =
  let rw = RWops.from_file ~filename ~mode:"rb" in
  let surf = Image.load_png_rw rw in
  let tex = Texture.create_from_surface renderer surf in
  let sprite_map = SpriteMap.add id tex sprite_map in
  Surface.free surf;
  (sprite_map)


let make_atlas width height tile_width tile_height =
  let num_x = width / tile_width in
  let num_y = height / tile_height in
  let length = num_x * num_y in
  let atlas = Array.make length {x = 0; y = 0; w = tile_width; h = tile_height } in
  for ny = 0 to num_y - 1 do
    for nx = 0 to num_x - 1 do
      atlas.(ny * num_x + nx) <- {x = nx * tile_width; y = ny * tile_height; w = tile_width; h = tile_height}
    done;
  done;
  atlas

  


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
  let sprite_map = SpriteMap.empty in
  let sprite_map = load_sprite renderer sprite_map "key1" "resources/sprites/godot.png" in
  let atlas = make_atlas 96 96 16 16 in
  let first_atlas = atlas.(0) in
  let render renderer =
    Render.clear renderer;
    Render.set_scale renderer (1.0, 1.0);
    Render.copy renderer ~texture:(SpriteMap.find "key1" sprite_map)
      ~src_rect:(Rect.make4 ~x:first_atlas.x ~y:first_atlas.y ~w:16 ~h:16)
      ~dst_rect:(Rect.make4 ~x:100 ~y:100 ~w:32 ~h:32)
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
