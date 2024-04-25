//
//  MainViewController.swift
//  MapBoxDemo
//
//  Created by imac-3700 on 2023/11/15.
//

import UIKit
import MapboxMaps


class MainViewController: UIViewController {
    
    internal var mapView: MapView!
    
    @IBOutlet weak var mapUIView: UIView!
    @IBOutlet weak var tbvRegion: UITableView!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var btnReload: UIButton!
    
    var tileRegions: [TileRegion] = []
    
    var offlineManager: OfflineManager!
    
    let dongyinbounds = CoordinateBounds(
        southwest: CLLocationCoordinate2D(latitude: 26.3465, longitude: 120.4596),
        northeast: CLLocationCoordinate2D(latitude: 26.3876, longitude: 120.5158)
    )
    
    let zuoyingbounds = CoordinateBounds(
        southwest: CLLocationCoordinate2D(latitude: 22.6457, longitude: 120.2426),
        northeast: CLLocationCoordinate2D(latitude: 22.7265, longitude: 120.3318)
    )
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
    }
    
    private func setupMapView() {
        tbvRegion.delegate = self
        tbvRegion.dataSource = self
        
        let myResourceOptions = ResourceOptions(accessToken: "pk.eyJ1IjoiaGFuZHNvbWVib3k3NzciLCJhIjoiY2xveWVweXplMDMxdzJrbWtteWpiN3VuYSJ9.0cZj7Ve5lnAKngTt5TfXgw")
        let myMapInitOptions = MapInitOptions(resourceOptions: myResourceOptions)
        
        mapView = MapView(frame: mapUIView.bounds, mapInitOptions: myMapInitOptions)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        self.view.addSubview(mapView)
        
        
        let tileStore = TileStore.default
        
        offlineManager = OfflineManager(resourceOptions: myResourceOptions)
    }
    
    func showMap(coordinate: CoordinateBounds) {
        try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: coordinate))
        let camera = mapView.mapboxMap.camera(for: coordinate, padding: .zero, bearing: 0, pitch: 0)
        
        mapView.mapboxMap.setCamera(to: camera)
    }
    
    func getOfflineMap(id: String, coordinate: CoordinateBounds) {
        let coordinates = [
            LocationCoordinate2D(latitude: coordinate.southwest.latitude,
                                 longitude: coordinate.southwest.longitude),
            LocationCoordinate2D(latitude: coordinate.northeast.latitude,
                                 longitude: coordinate.northeast.longitude),
            LocationCoordinate2D(latitude: coordinate.southwest.latitude,
                                 longitude: coordinate.northeast.longitude),
            LocationCoordinate2D(latitude: coordinate.northeast.latitude,
                                 longitude: coordinate.southwest.longitude)
        ]
        
        let polygon = Polygon([coordinates])
        let geometry = Geometry(polygon)
        let options = TilesetDescriptorOptions(styleURI: .light, zoomRange: 3 ... 16)
        let tilesetDescriptor = offlineManager.createTilesetDescriptor(for: options)
        let tileRegionLoadOptions = TileRegionLoadOptions(geometry: geometry, descriptors: [tilesetDescriptor])!
        
        TileStore.default.loadTileRegion(forId: id, loadOptions: tileRegionLoadOptions)  { _ in
            DispatchQueue.main.async {
                self.tbvRegion.reloadData()
                
                print("downloading...")
            }
        } completion: { result in
            switch result {
            case let .success(tileRegion):
                print("finish: \(tileRegion.id)")
            case let .failure(error):
                if case TileRegionError.canceled = error {
                    print("cancel error")
                } else {
                    print(error)
                }
            }
        }
    }
    
    @IBAction func downloadBtnClicked(_ sender: UIButton) {
        
        getOfflineMap(id: "Dongyin", coordinate: dongyinbounds)
        
        getOfflineMap(id: "Zuoying", coordinate: zuoyingbounds)
        
    }
    
    @IBAction func reloadBtnClicked(_ sender: UIButton) {
        TileStore.default.allTileRegions { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let regions):
                    self.tileRegions = regions
                    self.tbvRegion.reloadData()
                case .failure:
                    self.tileRegions = []
                }
            }
        }
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tileRegions.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50.0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell.init(style: .subtitle, reuseIdentifier: "cell")
        let tileRegion = tileRegions[indexPath.row]
        
        cell.textLabel?.text = "Region \(indexPath.row + 1): size:\(tileRegion.completedResourceSize)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tileRegion = tileRegions[indexPath.row]
        if tileRegion.id == "Dongyin" {
            let Dongyinbounds = CoordinateBounds(
                southwest: CLLocationCoordinate2D(latitude: 26.3404, longitude: 120.4552),
                northeast: CLLocationCoordinate2D(latitude: 26.3971, longitude: 120.5263)
            )
            try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: Dongyinbounds))
            
            // Center the camera on the bounds
            let camera = mapView.mapboxMap.camera(for: Dongyinbounds, padding: .zero, bearing: 0, pitch: 0)
            
            // Set the camera's center coordinate.
            mapView.mapboxMap.setCamera(to: camera)
            
        }
        
        if tileRegion.id == "Zuoying" {
            let Zuoyingbounds = CoordinateBounds(
                southwest: CLLocationCoordinate2D(latitude: 22.6457, longitude: 120.2426),
                northeast: CLLocationCoordinate2D(latitude: 22.7265, longitude: 120.3318)
            )
            try? mapView.mapboxMap.setCameraBounds(with: CameraBoundsOptions(bounds: Zuoyingbounds))
            
            // Center the camera on the bounds
            let camera = mapView.mapboxMap.camera(for: Zuoyingbounds, padding: .zero, bearing: 0, pitch: 0)
            
            // Set the camera's center coordinate.
            mapView.mapboxMap.setCamera(to: camera)
            
        }
    }
}




